requires 'Data::Printer';
requires 'Data::Random';
requires 'HTTP::Cookies';
requires 'JSON::MaybeXS';
requires 'LWP::UserAgent';
requires 'Moo';
requires 'Moo::Role';
requires 'Net::OAuth';
requires 'Types::Standard';
requires 'URI';
requires 'URI::Escape::XS';
requires 'URI::QueryParam';
requires 'XML::Simple';
requires 'match::smart';
requires 'namespace::autoclean';
requires 'perl', 'v5.6.2';
requires 'strictures', '2';

on test => sub {
    requires 'Test::More';
};
