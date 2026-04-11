([render]): use `..h;
/
  route.q
  This module defines routing for qlux. A router consists of a tree table of the following form:
  ([] 
    depth: int;
    rtype: one of root`index`static`matching`notfound; 
    name: sym; 
    page: f
  );
  The module exports the following:
  - `route` - function to define a route.
  - `static` - function to define a static route that uses the static handler.
  - `index` - function to define an index route
\

.z.m.int_route: {[x]
  if[-11h<>type x 0;'`route_name];
  has_page:  100h=type x 1;
  row: `depth`rtype`name`page!(0;`matching;x 0;(::;x 1) has_page);
  children: raze (1 2 has_page)_x;
  if[0=count children;:enlist row]; // return early if no children
  if[98<>type children;'`route_children];
  children[::;`depth]+: 1;
  row,children
  };

route: ('[.z.m.int_route;enlist]);

index: {
  enlist `depth`rtype`name`page!(0;`index;`;x)
  }

.z.m.int_terrifying_path_constituents: ("/*";"*..*";"*./*";"*/")

.z.m.int_static_handler: {[static_folder;not_found;static_path]
  static_path: (1+count string static_folder)_static_path;
  if[any static_path like/: .z.m.int_terrifying_path_constituents;'`bad_static_path];
  file_ext: `$max[1+where static_path="."]_static_path;
  file_handle: ` sv static_folder,`$static_path;
  if[()~key file_handle;:not_found[]];
  .h.hn["200";file_ext;10h$read1 file_handle]
  }

.z.m.int_default_not_found: {
  .h.hn["404";`html;.h.html
    render[h[`h1;"we couldn't find ur file :("]]`html
  ]}

static: {
  enlist `depth`rtype`name`page!(0;`static;x;.z.m.int_static_handler[hsym x;.z.m.int_default_not_found;])
  };

.z.m.int_parse_url: {[url]
  splits: count[url]&abs (min;max) @' where each url =/: "?#";
  splits: 0,(3#min splits;splits) 0 1 ~ iasc splits; / if ? appears before #, it's all good. if # appears before ?, chuck it out
  `path`params`anchor!3#splits _ url
  }

router: {[routes;request]
  parsed_url: .z.m.int_parse_url "/",request 0;
  search_path: parsed_url`path;  

  // look for matching static paths, and return if found
  static_matches: first select from routes where rtype like "static", search_path like/: (path,\:"/*");
  if[not ()~static_matches[`page];:static_matches[`page] search_path]; / return early on static match

  // look for a route match
  search_path: (0 -1 (not[search_path like enlist "/"]) & search_path like "*/")_search_path; // strip trailing backslash
  route_match: routes[enlist[`path]!enlist search_path];

  // if not found, bail with 404.
  if[null route_match`rtype;:.z.m.int_default_not_found[]];

  // if found, render page to html
  .h.hy[`html] .h.html render[route_match[`page][::]][`html]
  }

export: ([route;static;index;router])