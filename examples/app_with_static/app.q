\l ../../qlux.q

index: {
  .qlux.h[`div;
    .qlux.h[`h1;"Hello world!"];
    .qlux.h[`img;`width`src!("200px";"/static/logo.jpg")];
    .qlux.h[`p;"This is an example of some HTML written with qlux."];
    .qlux.h[`p;
      "You can pass attributes to elements to enable ";
      .qlux.h[`span;enlist[`style]!enlist "color: #ff0000";
        "styling"
      ];
      " or anything else you ";
      .qlux.h[`a;enlist[`href]!enlist "https://code.kx.com";"want"];
      enlist "!"
    ];
    .qlux.h[`p;
      "You can also create ";
      .qlux.h[`a;enlist[`href]!enlist "/settings/profile";"other"];
      enlist " ";
      .qlux.h[`a;enlist[`href]!enlist "/settings/privacy";"pages."]
      ]
  ]}

profile: {.qlux.h[`h1;"here's another page!"]}
privacy: {.qlux.h[`h1;"and another page!"]}


app: .qlux.app[
  .qlux.index[index];
  .qlux.route[`settings;
    .qlux.route[`profile;profile];
    .qlux.route[`privacy;privacy]
  ];
  .qlux.static[`static]
  ]

.z.ph: app
