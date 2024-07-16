using HTTP
using Gumbo
using AbstractTrees

href_attributes::Array{String} = []
metadata::Dict{String,String} = Dict()
disallow::Array{String} = []
sitemap::Array{String} = []

function robots_txt(rooturl)
    robots_url = rooturl * "/robots.txt"
    resp = HTTP.get(robots_url)
    robots_content = String(resp.body)

    for line in split(robots_content, '\n')
        if occursin("Disallow:", line)
            disallowed_url = split(line, " ")[2]
            push!(disallow, rooturl * disallowed_url)
        elseif occursin("Sitemap:", line)
            sitemap_url = split(line, " ")[2]
            push!(sitemap, sitemap_url)
        end
    end
end

function parseHtml(rooturl)
    try
        resp = HTTP.get(rooturl, ["User-Agent" => "julia-spider"], connect_timeout=3, readtimeout=3)

        if isempty(resp.body)
            println("No URLs found in the page: $rooturl")
            return
        end

        r_parsed = parsehtml(String(resp.body))
        root = r_parsed.root
        return root
    catch e
        println("Error fetching URL: ", e)
        return
    end
end

function crawl(root, rooturl, depth)
    if depth <= 0
        return
    end

    for elem in PostOrderDFS(root)
        try
            if tag(elem) == :a
                href = getattr(elem, "href")
                if startswith(href, "http")
                    push!(href_attributes, href)
                else
                    push!(href_attributes, rooturl * href)
                end
            elseif tag(elem) == :meta
                name = getattr(elem, "name", "")
                content = getattr(elem, "content", "")
                if !isempty(name) && !isempty(content)
                    metadata[name] = content
                end
            end
        catch e
            println("Error processing element: ", e)
        end
    end

    for link in href_attributes
        if !in(link, disallow)
            x = parseHtml(link)
            crawl(x, link, depth - 1)
        end
    end
end

robots_txt("https://crawler-test.com")
x = parseHtml("https://crawler-test.com")
println("Enter the recursion depth:")
depth = parse(Int, readline())
crawl(x, "https://crawler-test.com", depth)


println("Scraped URLs:")
for url in scraped_urls
    println(url)
end

println("Disallowed URLs:")
for disallowed_url in all_disallows
    println(disallowed_url)
end

println("Sitemap URLs:")
for sitemap_url in all_sitemaps
    println(sitemap_url)
end