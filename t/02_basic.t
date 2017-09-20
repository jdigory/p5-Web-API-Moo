use Test::More;                                                                                                                      

use lib 'lib';

BEGIN { use_ok('Web::API::Moo'); };

my $codes1 = Codes->new({ check => 200, retry => [ 200, 400 ] });
is(
    Web::API::Moo::needs_retry($codes1, $codes1),
    1,
    'needs_retry code in retry_http_codes'
);

my $codes2 = Codes->new({ check => 404, retry => [ 200, 400 ] });
isnt(
    Web::API::Moo::needs_retry($codes2, $codes2),
    1,
    'needs_retry code is not in retry_http_codes'
);

my $codes2 = Codes->new({ check => 404, retry => '404' });
is(
    Web::API::Moo::needs_retry($codes2, $codes2),
    1,
    'needs_retry code is in retry_http_codes, scalar, quoted'
);

my $codes2 = Codes->new({ check => 301, retry => 301 });
is(
    Web::API::Moo::needs_retry($codes2, $codes2),
    1,
    'needs_retry code is in retry_http_codes, scalar'
);

done_testing();

package Codes;
sub new {
    my $class = shift;
    my $args = shift || {};
    return bless { %$args }, $class;
}
sub debug {};
sub code { $_[0]->{check} };
sub retry_http_codes { $_[0]->{retry} };
sub retry_errors {};
1;
