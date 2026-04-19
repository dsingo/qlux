([describe;it;expect_eq;show_suite;show_sbt]): use `qlux.test;

describe["test 1";
  it["shows an example";{
      expect_eq[1b;1b;"To Pass"];
      expect_eq[1b;1b;"To Pass as well"]
    }]
  ];

describe["test 2";
  it["shows an example";{
      expect_eq[1b;1b;"To Pass"];
      expect_eq[0b;1b;"To Fail"]
    }]
  ]