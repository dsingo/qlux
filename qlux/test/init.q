DEPTH: 0;
TEST: 0;

/
  suite tree.
  d: depth.
  ttype: root, describe, it, expect
  name: string.
  pass: ``y`n.
\

.z.m.SUITE_TABLE: ([] d: 0; ttype: `root; name: enlist "root"; pass: `);

/
  expect throws
  key -> suite tree index
  val ->  dict
          ([
            left;
            right;
          ])
\
/
  backtraces
  key -> suite tree index
  val -> whatever .Q.trp spits out
\

.z.m.EXCEPT: ([ind: `int$()] error: `$(); trace: ());
.z.m.EXPECT_EQ: ([ind: `int$()] left: (); right: ());

.z.m.format_expect_stack_trace: {[trace:@[;1]]
  (;file;line;def): trace[1];
  pointer: trace[2];
  lines: "\n" vs def;
  line_pos: sums[0,1+count each lines] bin pointer;
  line_nums: string til[count lines] + line - line_pos;
  ruler_w: neg max count each line_nums;
  ,[;enlist "\033[0m"] ,[enlist "\033[2m";] "" sv/: flip (
    @[4#();line_pos;:;"\033[0m"];
    line_nums,\:"\t";
    lines;
    @[4#();line_pos;:;"\033[2m"]
    )
  }

describe: ('[{[args]
  .z.M.SUITE_TABLE insert (.z.m.DEPTH;`describe;args 0;`);
  .z.m.DEPTH+:1;
  (1_args) @\: (::);
  .z.m.DEPTH-:1;
  };enlist]);

it: {[name;test]
  {[name;test;unused_arg]
    .z.m.DEPTH+:1;
    .z.M.SUITE_TABLE insert (.z.m.DEPTH;`it;name;`);
    .Q.trp[{[f] f[(::)];
      update pass:`y from .z.M.SUITE_TABLE where i = max i;
      };test;{[x;y]
      update pass: `n from .z.M.SUITE_TABLE where i = max i;
      .z.M.EXCEPT insert (count[.z.m.SUITE_TABLE] - 1;`$x;y);
      }];
    .z.m.DEPTH-:1;
    }[name;test]
  };

expect_eq: {[l;r;message]
    if[l~r;:(::)];
    .z.m.EXPECT_EQ[count[.z.m.SUITE_TABLE] - 1]: ([
      left: 20 sublist .Q.s1 l;
      right: 20 sublist .Q.s1 r;
      trace: ()
    ]);
    '`expect
  };

show_suite: {
  suite: .z.m.SUITE_TABLE;
  suite: update 
    p: 0^{x bin[x;y]}[;i] group[suite[`d]] suite[`d] min[i] - 1 by d
    from
    suite;
  suite: ({
    update 
      pass:`n`y min'[(`y=x[`pass])[group[x`p] except\: i]] i 
      from x 
      where null pass, not[i in p] or 1=count i}/) suite;
  
  -1 exec 
    "  " sv/: flip (d#\:"  ";("\033[31m✘ FAILED";"\033[32m✓ PASSED") `y=pass;name,\:"\033[0m") 
      from suite 
      where i<>0, ttype<>`expect;
  summary: exec ([tests: count i;passed:sum pass=`y;failed:sum pass=`n]) from suite where ttype = `it;
  -1 ", " sv " " sv/: string each flip (value;key) @\:  #[;summary] where summary<>0;
  exit 0;
  // .z.m.SUITE_TABLE
  };

// show_sbt: {.z.m.format_expect_stack_trace .z.m.EXPECT_EQ[4][`trace]};
.z.ts: show_suite;
system "t 1";

export: ([describe;it;expect_eq;show_suite]);