using HTTP
using Gumbo
using AbstractTrees
using Match

href_attributes::Array{String} = []
urls::Dict{String,String} = Dict()
disallow::Array{String} = []
sitemap::Array{String} = []

url = "https://en.wikipedia.org/wiki/Julius_Caesar"

function root_parser(url::String)::String
    # Regular expression to match the root URL
    match = Match.match(r"(https?://[^/]+)/", url)
    if match !== nothing
        return match.match
    else
        error("Invalid URL format")
    end
end

function robots_txt(rooturl)
    robots_url = rooturl * "/robots.txt"
    robots_content = ""
    try
        resp = HTTP.get(robots_url)
        robots_content = String(resp.body)
    catch e
        println("Exception occured:", e)
    end
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
        resp = HTTP.get(rooturl, ["User-Agent" => "julia-spider"], connect_timeout=2, readtimeout=2)

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
                href_value = AbstractTrees.children(elem)[1].text
                #println(typeof(href_value))
                if startswith(href, "http")
                    push!(href_attributes, href)
                    urls[href_value] = href
                else
                    push!(href_attributes, rooturl * href)
                    urls[href_value] = rooturl * href
                end
            end
        catch e
            #println("Error processing element: ", e)
        end
    end

    for link in href_attributes
        if !in(link, disallow)
            x = parseHtml(link)
            crawl(x, link, depth - 1)
        end
    end
end

root_url = root_parser(url)
println(root_url)  # Output: https://en.wikipedia.org

robots_txt(url)
x = parseHtml(url)
println("Enter the recursion depth:")
depth = parse(Int, readline())
crawl(x, url, depth)


println("Scraped URLs:")
for url in href_attributes
    println(url)
end

println("Disallowed URLs:")
for disallowed_url in disallow
    println(disallowed_url)
end

println("Sitemap URLs:")
for sitemap_url in sitemap
    println(sitemap_url)
end

println("urls")
for (key, value) in urls
    println("$key: \t\t\t$value")
end