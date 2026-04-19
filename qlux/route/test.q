([describe;it;expect_eq]): use `qlux.test;
([route; router]): use `.route;

no_param: {(matcher:x;params: {x!x}(`$()))};

describe[
  "Path Matching and Composition";
  it["Should match a single segment";
    {[]
      r: enlist route[`GET;"test";1];
      res: router[r][`GET;"/test"];
      expect_eq[1;res `handler;"Single route matches"];
      }
    ];
  it["Should match multiple segments";
    {[]
      r: (
        route["test"] (
          route[`GET;1];
          route["test"] (
            route[`GET;2]
            )
          )
        );
      matcher: router[r];
      expect_eq[
        matcher[`GET;"/test"] `handler;
        1;
        "matches first get"
        ];
      expect_eq[
        matcher[`GET;"/test/test"] `handler;
        2;
        "matches nested get"
        ]
      }
    ];
  it["Should match index";
    {[]
      r: (
        route[`GET;1];
        route["test"] (
          route[`GET;2]
          )
        );
      matcher: router[r];
      expect_eq[
        matcher[`GET;"/"] `handler;
        1;
        "matches index"
        ];
      expect_eq[
        matcher[`GET;"/test"] `handler;
        2;
        "matches test"
        ]
      }
    ]
  ];

describe[
  "Method dispatch";
  it["Should route to correct method, inclusive of nesting.";
    {[]
      r: (
        route[`GET;1];
        route[`POST;2];
        route["user"] (
          route[`GET;3];
          route[`POST;4]
          )
        );
      matcher: router[r];
      expect_eq[
        matcher[`GET;"/"] `handler;
        1;
        "Selects index GET method"
        ];
      expect_eq[
        matcher[`POST;"/"] `handler;
        2;
        "Selects index POST method"
        ];
      expect_eq[
        matcher[`GET;"/user"] `handler;
        3;
        "Selects test GET method"
        ];
      expect_eq[
        matcher[`POST;"/user"] `handler;
        4;
        "Selects test POST method"
        ];
      }
    ];
  it["Should throw 405 if method does not exist on route";
    {[]
      r: (
        route[`GET;1];
        route["test"] (
          route[`GET;2]
          )
        );
      matcher: router[r];
      expect_eq[
        .[{x[y]};(handler;(`PUT;"/"));{`$x}];
        `405;
        "Should throw 405 on bad index route"
        ];
      expect_eq[
        .[{x[y]};(handler;(`PUT;"/test"));{`$x}];
        `405;
        "Should throw 405 on bad test route"
        ];
      }
    ];
    it["Should throw 404 if route does not exist";
    {[]
      r: (
        route[`GET;1];
        route["test"] (
          route[`GET;2]
          )
        );
      matcher: router[r];
      expect_eq[
        .[{x[y]};(handler;(`PUT;"/bad"));{`$x}];
        `404;
        "Should throw 404 on bad route"
        ];
      expect_eq[
        .[{x[y]};(handler;(`PUT;"/test/bad"));{`$x}];
        `404;
        "Should throw 404 on bad nested route"
        ];
      }
    ]
  ];

describe[
  "Parameters";
  it["Should capture parameters";
    {[]
      r: (
        route["test"] (
          route[":param"] (
            route[`GET;1]
            )
          )
        );
      matcher: router[r];
      res: matcher[`GET;"/test/123"];
      expect_eq[
        res `handler;
        1;
        "matches handler"
        ];
      expect_eq[
        res . `params`param;
        "123";
        "extracts parameter"
        ]
      }
    ];
  it["Should capture nested parameters";
    {[]
      r: route["test"] (
          route[":one"] (
            route["test"] (
              route[":two"] (
                route[`GET;1]
              )
            )
          )
        );
      matcher: router[r];
      res: matcher[`GET;"/test/abc/test/123"];
      expect_eq[
        res `handler;
        1;
        "Expect route to work"
        ];
      expect_eq[
        res . `params`one;
        "abc";
        "Extract first parameter"
        ];
      expect_eq[
        res . `params`two;
        "123";
        "Extract two parameters"
        ]
      }
    ]
  ];

describe[
  "Wildcards";
  it["Should match wildcards";
    {[]
      r: (
        route["files"] (
            route[`GET;"*";1]
          )
        );
      matcher: router[r];
      res: matcher[`GET;"files/images/hero.jpg"];
      expect_eq[
        res`handler;
        1;
        "Matches handler"
        ];
      expect_eq[
        res . `wildcards`;
        "images/hero.jpg";
        "Extract wildcard segment correctly"
        ]
      }
    ];
  it["Should match named wildcards";
    {[]
      r: (
        route["files"] (
            route[`GET;"*file";1]
          )
        );
      matcher: router[r];
      res: matcher[`GET;"files/images/hero.jpg"];
      expect_eq[
        res`handler;
        1;
        "Matches handler"
        ];
      expect_eq[
        res . `wildcards`file;
        "images/hero.jpg";
        "Extract wildcard segment correctly"
        ]
      }
    ]
  ];

describe[
  "Specificity";
  it["Static beats params";
    {[]
      r: route["user"] (
        route[`GET;"create";1];
        route[`GET;":id";2]
        );
      matcher: router[r];
      expect_eq[
        matcher[`GET;"/user/create"] `handler;
        1;
        "Match static route first"
        ];
      expect_eq[
        matcher[`GET;"/user/blah"] `handler;
        2;
        "Match param when no static match"
        ]
      }
    ];
  it["Params beat wildcard";
    {[]
      r: route["files"] (
        route[":id"] (
          route[`GET;1];
          route[`GET;":name";2];
          );
        route[`GET;"*";3]
        );
      matcher: router[r];
      expect_eq[
        matcher[`GET;"/files/123"] `handler;
        1;
        "Params beat wildcards"
        ];
      expect_eq[
        matcher[`GET;"/files/123/456"] `handler;
        2;
        "Nested params beat wildcard"
        ];
      expect_eq[
        matcher[`GET;"/files/123/456/789"] `handler;
        3;
        "Wildcard matches when no params"
        ]
      }
    ]
  ];

describe[
  "Conflict detection";
  it["Should detect static conflict";
    {[]
      r: (
        route[`GET;"abc";1];
        route[`GET;"abc";2]
        );
      expect_eq[
        @[router;r;{`$x}];
        `conflict;
        "detects static conflicts"
        ]
      }
    ];
  it["Should detect param conflict";
    {[]
      r: (
        route[`GET;":id";1];
        route[`GET;":z";1];
        );
            expect_eq[
      @[router;r;{`$x}];
        `conflict;
        "detects param conflicts"
        ]
      }
    ];
  it["Should detect static under param conflict";
    {[]
      good: (
        route[":id"] (
          route[`GET;"abc";1]
          );
        route[":name"] (
          route[`GET;"xyz";1]
          )
        );
      router[good];
      bad: (
        (
        route[":id"] (
          route[`GET;"abc";1]
          );
        route[":name"] (
          route[`GET;"abc";1]
          )
        );
      );
      expect_eq[
        @[router;bad;{`$x}];
        `conflict;
        "Throws on conflicted static routes"
        ]
      }
    ];
  it["Should detect wildcard conflicts";
    {[]
      okay: (
        route[`GET;"*";1];
        route[`POST;"*";2]
      );
      router[okay];
      immediate: (
        route[`GET;"*";1]
        route[`GET;"*";2]
        );
      expect_eq[
        @[router;immediate;{`$x}];
        `conflict;
        "Throws on conflicted wildcards"
        ];
      arbitrary_depth: (
        route["files"] (
          route[":id"] (
            route[`GET;1];
            route[`GET;":name";2];
            route[`GET;"*";3]
          );
          route[`GET;"*";4]
          )
        );
      expect_eq[
        @[router;arbitrary_depth;{`$x}];
        `conflict;
        "Throws on arbitrary depth conflicts"
        ]
      }
    ]
  ];

describe[
  "Input normalisation";
  it["Should strip url params";
    {[]
      r: enlist route[`GET;"test";1];
      res: router[r][`GET;"/test?id=123"];
      expect_eq[1;res `handler;"Single route matches"];
      }
    ];
  it["Should strip trailing slashes";
    {[]
      r: enlist route[`GET;"test";1];
      res: router[r][`GET;"/test/"];
      expect_eq[1;res `handler;"Single route matches"];
      }
    ]
  ];
