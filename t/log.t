
use Test::More tests => 8;
BEGIN { use_ok('Varnish::API') };
use Devel::Peek;

use Sys::Hostname qw(hostname);

my $vd = Varnish::API::VSL_New();
Varnish::API::VSL_OpenLog($vd, hostname);
Varnish::API::VSL_Dispatch($vd, sub { ok(1, "dispatch callback called"); return 1});

{
  my $i = 0;
  Varnish::API::VSL_Dispatch($vd, sub {
			       $i
				 ? ok(1, "second time return 1 and exit dispatcher")
				   : ok(1, "return 0 and enter the dispatch loop once more");
			       return $i++;
			     });
}

Varnish::API::VSL_Dispatch($vd, sub {
			     my @args = @_;
			     is(@args, 4, "there are 4 arguments");
			     like($args[0], qr /^\w+$/, "First argument is tag text");
			     like($args[1], qr /^\d+$/, "Second is the fd number");
			   });


Varnish::API::VSL_Arg($vd, ord("i"), "CLI");

Varnish::API::VSL_Dispatch($vd, sub {
			     my @args = @_;
			     is ($_[0], "CLI", "Only CLI allowed");
			     return 1;
			   });
