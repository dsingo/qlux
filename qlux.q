.qlux.int.default_attributes: (`symbol$())!();
.qlux.int.tags: `h1`p`div`span`a`img`h2;
.qlux.int.elems: `qlux_text,.qlux.int.tags;

.qlux.int.h: {[args]
  arg_types: type each args;

  // element correctness checking.
  if[-11h <> arg_types 0;'`elem]; // raise on non-symbol element.
  if[not args[0] in .qlux.int.elems;'args 0]; // raise on bad elements.
  
  // children correctness checking
  children_start: (1;2) 99h=arg_types 1;
  if[any not (children_start _ arg_types) in 98 10h;'`children]; // raise on incompatible children;
  
  // property correctness checking
  properties: (.qlux.int.default_attributes;args 1) children_start=2;
  if[any not type'[value properties] in 10 -10 -9 -7h;'`badprop]; / throw on unsupported properties.
  
  element: `node_type`depth`content`attrs!(args 0;0;"";properties);
  children: children_start _ args;
  if[0=count children;:enlist element];
  text_elems: where 10h = children_start _ arg_types;
  children[text_elems]: enlist each ([] 
    node_type:`qlux_text; 
    depth: 0;
    content: .h.xs each children text_elems; 
    attrs: (count text_elems)#enlist .qlux.int.default_attributes
  );
  children[::;::;`depth]+: 1;

  element,raze children
  };

.qlux.h: ('[.qlux.int.h;enlist]);

.qlux.int.attribute_sanitizers: (enlist'["\"'\\"];("&quot;";"&apos;";"\\\\"))

.qlux.int.make_attribute_values: {[vals]
  "\"",/:/:((ssr/[;
    .qlux.int.attribute_sanitizers 0;
    .qlux.int.attribute_sanitizers 1])''[vals]),\:\:"\""
  }

()

.qlux.int.produce_simple_start_tags: .qlux.int.tags!"<",/:string[.qlux.int.tags],\:">"

.qlux.int.produce_start_tags: {[elem;props]
  complex_tags: 0<>count'[props];
  if[not any complex_tags;:.qlux.int.produce_simple_start_tags elem]; / bail early if all elements are simple.
  tags: count[elem]#enlist "";
  tags[where not complex_tags]: .qlux.int.produce_simple_start_tags elem where not complex_tags;
  tags[where complex_tags]:  "<",/:string[elem where complex_tags] ,' " ",/:(
    " " sv/: "=" sv/:/: (flip') flip (
      string key each props where complex_tags;
      .qlux.int.make_attribute_values value each props where complex_tags)
    ),\:">";
  tags
  }


.qlux.int.produce_end_tags: .qlux.int.tags!"</",/:string[.qlux.int.tags],\:">"

.qlux.render: {[tree]
  tree: update parent: 0^{x bin[x;y]}[;i] group[tree `depth] tree[`depth] min[i] - 1 by depth from tree;
  tree: update 
    st: .qlux.int.produce_start_tags[node_type;attrs],
    et: .qlux.int.produce_end_tags node_type from tree where node_type in .qlux.int.tags;
  parent_map: exec first parent by i from tree where i=(max;i) fby parent;
  tree: update html: (st,'content) from tree;
  tree: update html: (html ,' raze'[tree[`et] @ (parent_map\) each i]) from tree where not i in parent, i=(max;i) fby parent;
  exec html: raze html from tree
  };


// routes

// ([] depth: int; rtype:[root;index;static;matching;notfound]; name: sym; page: f)

.qlux.int.route: {[x]
  if[-11h<>type x 0;'`route_name];
  has_page:  100h=type x 1;
  row: `depth`rtype`name`page!(0;`matching;x 0;(::;x 1) has_page);
  children: raze (1 2 has_page)_x;
  if[0=count children;:enlist row]; // return early if no children
  if[98<>type children;'`route_children];
  children[::;`depth]+: 1;
  row,children
  }

.qlux.route: ('[.qlux.int.route;enlist])

.qlux.index: {
  enlist `depth`rtype`name`page!(0;`index;`;x)
  }

.qlux.int.terrifying_path_constituents: ("/*";"*..*";"*./*";"*/")

.qlux.int.static_handler: {[static_folder;not_found;static_path]
  static_path: (1+count string static_folder)_static_path;
  if[any static_path like/: .qlux.int.terrifying_path_constituents;'`bad_static_path];
  file_ext: `$max[1+where static_path="."]_static_path;
  file_handle: ` sv static_folder,`$static_path;
  if[()~key file_handle;:not_found[]];
  .h.hn["200";file_ext;10h$read1 file_handle]
  }

.qlux.int.default_not_found: {
  .h.hn["404";`html;.h.html
    .qlux.render[.qlux.h[`h1;"we couldn't find ur file :("]]`html
  ]}

.qlux.static: {
  enlist `depth`rtype`name`page!(0;`static;x;.qlux.int.static_handler[hsym x;.qlux.int.default_not_found;])
  };

.qlux.int.parse_url: {[url]
  splits: count[url]&abs (min;max) @' where each url =/: "?#";
  splits: 0,(3#min splits;splits) 0 1 ~ iasc splits; / if ? appears before #, it's all good. if # appears before ?, chuck it out
  `path`params`anchor!3#splits _ url
  }

.qlux.int.router: {[routes;request]
  parsed_url: .qlux.int.parse_url "/",request 0;
  search_path: parsed_url`path;  

  // look for matching static paths, and return if found
  static_matches: first select from routes where rtype like "static", search_path like/: (path,\:"/*");
  if[not ()~static_matches[`page];:static_matches[`page] search_path]; / return early on static match

  // look for a route match
  search_path: (0 -1 (not[search_path like enlist "/"]) & search_path like "*/")_search_path; // strip trailing backslash
  route_match: routes[enlist[`path]!enlist search_path];

  // if not found, bail with 404.
  if[null route_match`rtype;:.qlux.int.default_not_found[]];

  // if found, render page to html
  .h.hy[`html] .h.html .qlux.render[route_match[`page][::]][`html]
  }

.qlux.int.app: {[routes]
  root: enlist `depth`rtype`name`page!(0;`root;`;::);
  routes: update depth: depth+1 from raze routes;
  if[98<>type routes;'`app_routes];
  routes: root,routes;
  routes: update parent: 0^{x bin[x;y]}[;i] group[routes `depth] routes[`depth] min[i] - 1 by depth from routes;
  tree_map: exec i!parent from routes;
  routes: update traversal: ('[reverse;tree_map\]) each i from routes where rtype in `index`matching`static;
  .qlux.int.router select page: ('[;]/) routes[`page] first traversal, first rtype by path: "/" sv/: string routes[`name] @ traversal from routes where rtype in `index`matching`static
  };

.qlux.app: ('[.qlux.int.app;enlist])
