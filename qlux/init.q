([static;route;index;router]): use `.route;
([h;render]): use `.h;

.z.m.int_app: {[routes]
  root: enlist `depth`rtype`name`page!(0;`root;`;::);
  routes: update depth: depth+1 from raze routes;
  if[98<>type routes;'`app_routes];
  routes: root,routes;
  routes: update parent: 0^{x bin[x;y]}[;i] group[routes `depth] routes[`depth] min[i] - 1 by depth from routes;
  tree_map: exec i!parent from routes;
  routes: update traversal: ('[reverse;tree_map\]) each i from routes where rtype in `index`matching`static;
  router select page: ('[;]/) routes[`page] first traversal, first rtype by path: "/" sv/: string routes[`name] @ traversal from routes where rtype in `index`matching`static
  };

app: ('[.z.m.int_app;enlist])

export: ([app;h;static;route;index;render])
