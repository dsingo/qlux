
.z.m.int_default_attributes: (`symbol$())!();
.z.m.int_tags: `h1`p`div`span`a`img`h2`h3`pre`ul`li;
.z.m.int_elems: `qlux_text,.z.m.int_tags;

.z.m.int_h: {[args]
  arg_types: type each args;

  // element correctness checking.
  if[-11h <> arg_types 0;'`elem]; // raise on non-symbol element.
  if[not args[0] in .z.m.int_elems;'args 0]; // raise on bad elements.
  
  // children correctness checking
  children_start: (1;2) 99h=arg_types 1;
  if[any not (children_start _ arg_types) in 0 98 10h;'`children]; // raise on incompatible children;
  
  // property correctness checking
  properties: (.z.m.int_default_attributes;args 1) children_start=2;
  if[any not type'[value properties] in 10 -10 -9 -7h;'`badprop]; / throw on unsupported properties.
  
  element: `node_type`depth`content`attrs!(args 0;0;"";properties);
  children: children_start _ args;
  if[0=count children;:enlist element];
  text_elems: where 10h = children_start _ arg_types;
  children[text_elems]: enlist each ([] 
    node_type:`qlux_text; 
    depth: 0;
    content: .h.xs each children text_elems; 
    attrs: (count text_elems)#enlist .z.m.int_default_attributes
  );
  list_elems: where 0h = children_start _ arg_types;
  children[list_elems]: raze each children list_elems;
  children[::;::;`depth]+: 1;

  element,raze children
  };

h: ('[.z.m.int_h;enlist]);

.z.m.int_attribute_sanitizers: (enlist'["\"'\\"];("&quot;";"&apos;";"\\\\"))

.z.m.int_make_attribute_values: {[vals]
  "\"",/:/:((ssr/[;
    .z.m.int_attribute_sanitizers 0;
    .z.m.int_attribute_sanitizers 1])''[vals]),\:\:"\""
  }

.z.m.int_produce_simple_start_tags: .z.m.int_tags!"<",/:string[.z.m.int_tags],\:">"

.z.m.int_produce_start_tags: {[elem;props]
  complex_tags: 0<>count'[props];
  if[not any complex_tags;:.z.m.int_produce_simple_start_tags elem]; / bail early if all elements are simple.
  tags: count[elem]#enlist "";
  tags[where not complex_tags]: .z.m.int_produce_simple_start_tags elem where not complex_tags;
  tags[where complex_tags]:  "<",/:string[elem where complex_tags] ,' " ",/:(
    " " sv/: "=" sv/:/: (flip') flip (
      string key each props where complex_tags;
      .z.m.int_make_attribute_values value each props where complex_tags)
    ),\:">";
  tags
  }


.z.m.int_produce_end_tags: .z.m.int_tags!"</",/:string[.z.m.int_tags],\:">"

render: {[tree]
  tree: update parent: 0^{x bin[x;y]}[;i] group[tree `depth] tree[`depth] min[i] - 1 by depth from tree;
  tree: update 
    st: .z.m.int_produce_start_tags[node_type;attrs],
    et: .z.m.int_produce_end_tags node_type from tree where node_type in .z.m.int_tags;
  parent_map: exec first parent by i from tree where i=(max;i) fby parent;
  tree: update html: (st,'content) from tree;
  tree: update html: (html ,' raze'[tree[`et] @ (parent_map\) each i]) from tree where not i in parent, i=(max;i) fby parent;
  exec html: raze html from tree
  };

export: ([h;render]);