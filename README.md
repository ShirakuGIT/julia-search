# Julia Search
## A rudimentary search engine implementation in Julia
Julia Search is a simple search engine written completely in Julia. It performs the following fundamental functionalities of a Search Engine:
1. Web Crawling
2. Search Indexing
3. Searching & Ranking

### Feature Set
- Follows Robots Exclusion Protocol as per [RFC 9309](https://en.wikipedia.org/wiki/Robots.txt#:~:text=The%20%22robots.txt%22%20file%20can%20be%20used%20in%20conjunction%20with%20sitemaps,%20another%20robot%20inclusion%20standard%20for%20websites.)
- Follows Sitemaps Protocol in conjunction with Robots
- more features in the future!

## Task Management {Constantly Updated}

 - [ ] Implement Web Crawler - {Future Revisions will occur}
	 - [x] Configure HTTP requests
	 - [x] Implement recursive search
	 - [x] Restrict to [Robots Exclusion Protocol](https://en.wikipedia.org/wiki/Robots.txt)
	 - [ ] Restrict to [Sitemaps](https://en.wikipedia.org/wiki/Sitemaps) Protocol
	 - [ ] Store Metadata
 - [ ] Implement Search Indexing - {Future Revisions will occur}
 - [ ] Implement Searching & Ranking - {Future Revisions will occur}

## Packages Used
1. HTTP
2. Gumbo
3. AbstractTrees
