# NAME

Web::API::Moo - quickly implement a REST API

# SYNOPSIS

Implement the RESTful API of your choice in 10 minutes, roughly.

```
    package Net::CloudProvider;

    use Moo;

    with 'Web::API::Moo';

    our $VERSION = "0.1";

    has 'commands' => (
        is      => 'rw',
        default => sub {
            {
                list_nodes => { method => 'GET' },
                node_info  => { method => 'GET', require_id => 1 },
                create_node => {
                    method             => 'POST',
                    default_attributes => {
                        allowed_hot_migrate            => 1,
                        required_virtual_machine_build => 1,
                        cpu_shares                     => 5,
                        required_ip_address_assignment => 1,
                        primary_network_id             => 1,
                        required_automatic_backup      => 0,
                        swap_disk_size                 => 1,
                    },
                    mandatory => [
                        'label',
                        'hostname',
                        'template_id',
                        'cpus',
                        'memory',
                        'primary_disk_size',
                        'required_virtual_machine_build',
                        'cpu_shares',
                        'primary_network_id',
                        'required_ip_address_assignment',
                        'required_automatic_backup',
                        'swap_disk_size',
                    ]
                },
                update_node => { method => 'PUT',    require_id => 1 },
                delete_node => { method => 'DELETE', require_id => 1 },
                start_node  => {
                    method       => 'POST',
                    require_id   => 1,
                    post_id_path => 'startup',
                },
                stop_node => {
                    method       => 'POST',
                    require_id   => 1,
                    post_id_path => 'shutdown',
                },
                suspend_node => {
                    method       => 'POST',
                    require_id   => 1,
                    post_id_path => 'suspend',
                },
            };
        },
    );

    sub commands {
        my ($self) = @_;
        return $self->commands;
    }

    sub BUILD {
        my ($self) = @_;

        $self->user_agent(__PACKAGE__ . ' ' . $VERSION);
        $self->base_url('https://ams01.cloudprovider.net/virtual_machines');
        $self->content_type('application/json');
        $self->extension('json');
        $self->wrapper('virtual_machine');
        $self->mapping({
                os        => 'template_id',
                debian    => 1,
                id        => 'label',
                disk_size => 'primary_disk_size',
        });

        return $self;
    }

    1;
```

later use as:

```
    use Net::CloudProvider;

    my $nc = Net::CloudProvider->new(user => 'foobar', api_key => 'secret');
    my $response = $nc->create_node({
        id                             => 'funnybox',
        hostname                       => 'node.funnybox.com',
        os                             => 'debian',
        cpus                           => 2,
        memory                         => 256,
        disk_size                      => 5,
        allowed_hot_migrate            => 1,
        required_virtual_machine_build => 1,
        cpu_shares                     => 5,
        required_ip_address_assignment => 1,
    });
```

# ATTRIBUTES

## commands

most important configuration part of the module which has to be provided by the
module you are writing.

the following keys are valid/possible:

    method
    path
    mandatory
    default_attributes
    headers
    extension
    content_type
    incoming_content_type
    outgoing_content_type
    wrapper
    require_id (deprecated, use path)
    pre_id_path (deprecated, use path)
    post_id_path (deprecated, use path)

the request path for commands is being build as:

    $base_url/$path.$extension

an example for `path`:

    path => 'users/:user_id/labels'

this will add `user_id` to the list of mandatory keys for this command
automatically.

## base\_url (required)

get/set base URL to API, can include paths

## api\_key (required in most cases)

get/set API key (also used as basic auth password)

## user (optional)

get/set API username/account name

## api\_key\_field (optional)

get/set name of the hash key that has to hold the `api_key`
e.g. in POST content payloads

## mapping (optional)

supply mapping table, hashref of format { "key" => "value", ... }

## wrapper (optional)

get/set name of the key that is used to wrap all options of a command in.
unfortunately some APIs increase the depth of a hash by wrapping everything into
a single key (who knows why...), which means this:

    $wa->command(%options);

turns `%options` into:

    { wrapper => \%options }

before encoding and sending it off.

## header (optional)

get/set custom headers sent with every request

## auth\_type

get/set authentication type. currently supported are only 'basic', 'hash\_key', 'get\_params', 'oauth\_header', 'oauth\_params' or 'none'

default: none

## default\_method (optional)

get/set default HTTP method

default: GET

## extension (optional)

get/set file extension, e.g. '.json'

## user\_agent (optional)

get/set User Agent String

default: "Web::API::Moo $VERSION"

## timeout (optional)

get/set [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) timeout

## strict\_ssl (optional)

enable/disable strict SSL certificate hostname checking as a convenience
alternatively you can supply your own LWP::Useragent compatible agent for
the `agent` attribute.

default: true

## agent (optional)

get/set [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) object

## retry\_http\_codes (optional)

get/set array of HTTP response codes that trigger a retry of the request

## retry\_errors (optional)

define an array reference of regexes that should trigger a retry of the request
if matched against an error found via one of the `error_keys`

## retry\_times (optional)

get/set amount of times a request will be retried at most

default: 3

## retry\_delay (optional)

get/set delay to wait between retries. accepts float for millisecond support.

default: 1.0

## content\_type (optional)

global content type, which is used for in and out going request/response
headers and to encode and decode the payload if no other more specific content
types are set, e.g. `incoming_content_type`, `outgoing_content_type` or
content types set individually per command attribute.

default: 'text/plain'

## incoming\_content\_type (optional)

default: undef

## outgoing\_content\_type (optional)

default: undef

## debug (optional)

enable/disabled debug logging

default: false

## cookies (optional)

this is used to store and retrieve cookies before and after requests were made
to keep authenticated sessions alive for the time this object exists in memory
you can add your own cookies to be send with every request. See
[HTTP::Cookies](https://metacpan.org/pod/HTTP::Cookies) for more information.

default: HTTP::Cookies->new()

## consumer\_secret (required for all oauth\_\* auth\_types)

default: undef

## access\_token (required for all oauth\_\* auth\_types)

default: undef

## access\_secret (required for all oauth\_\* auth\_types)

default: undef

## signature\_method (required for all oauth\_\* auth\_types)

default: undef

## encoder (custom options encoding subroutine)

Receives `\%options` and `content-type` as the only 2 arguments and has to
return a single scalar.

default: undef

## decoder (custom response content decoding subroutine)

Receives `content` and `content-type` as the only 2 scalar arguments and has
to return a single hash reference.

default: undef

## oauth\_post\_body (required for all oauth\_\* auth\_types)

enable/disable adding of command options as extra parameters to the OAuth
request generation and therefor be included in the OAuth signature calculation.

default: true

## error\_keys

get/set list of array keys that will be search for in the decoded response data
structure. the same format as for mandatory keys is supported:

    some.deeply.nested.error.message

will search for an error message at

    $decoded_response->{some}->{deeply}->{nested}->{error}->{messsage}

and if the key exists and its value is defined it will be provided as
`$response-`{error}> and matched against all regexes from the \`retry\_errors\`
array ref if provided to trigger a retry on particular errors.

# INTERNAL SUBROUTINES/METHODS

## nonce

generates new OAuth nonce for every request

## log

## decode

## encode

## talk

## map\_options

## key\_exists

## wrap

## request

retry request with delay if `retry_http_codes` is set, otherwise just try once.

## needs\_retry

returns true if the HTTP code or error found match either `retry_http_codes`
or `retry_errors` respectively.
returns false otherwise.

if `retry_errors` are defined it will try to decode the response content and
store the decoded structure internally so we don't have to decode again at the
end.

needs the last response object and the 'Accept' content type header from the
request for decoding.

## find\_error

go through `error_keys` and find a potential error message in the decoded/parsed
response and return it.

## format\_response

## build\_uri

## build\_content\_type

configure in/out content types

order of precedence:
1\. per command `incoming_content_type` / `outgoing_content_type`
2\. per command general `content_type`
3\. content type based on file path extension (only for incoming)
4\. global `incoming_content_type` / `outgoing_content_type`
5\. global general `content_type`

## DESTROY

catch DESTROY call and tear down / clean up if necessary
at this point there is nothing to do though. This prevents
AUTOLOAD from logging an unknown command error message

## AUTOLOAD magic

install a method for each new command and call it in an `eval {}` to catch
exceptions and set an error in a unified way.

# BUGS

Please report any bugs or feature requests on GitHub's issue tracker [https://github.com/jdigory/p5-Web-API-Moo/issues](https://github.com/jdigory/p5-Web-API-Moo/issues).
Pull requests welcome.

# SUPPORT

You can find documentation for this module with the [perldoc(1)](http://man.he.net/man1/perldoc) command.

    perldoc Web::API::Moo

You can also look for information at:

- GitHub repository

    [https://github.com/jdigory/p5-Web-API-Moo](https://github.com/jdigory/p5-Web-API-Moo)

- MetaCPAN

    [https://metacpan.org/module/Web::API::Moo](https://metacpan.org/module/Web::API::Moo)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Web::API::Moo](http://annocpan.org/dist/Web::API::Moo)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Web::API::Moo](http://cpanratings.perl.org/d/Web::API::Moo)

# SEE ALSO

[Web::API](https://metacpan.org/pod/Web::API), [HTTP::Cookies](https://metacpan.org/pod/HTTP::Cookies), [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent), [Net::OAuth](https://metacpan.org/pod/Net::OAuth)
