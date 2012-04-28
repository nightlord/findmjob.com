package FindmJob::ShareBot::Reddit;

use Moose;
use namespace::autoclean;
with 'FindmJob::ShareBot::Role';

use Reddit;

has 'reddit' => ( is => 'ro', isa => 'Reddit', lazy_build => 1 );
sub _build_reddit {
    my $self = shift;
    my $config = $self->config;
    my $t = $config->{share}->{Reddit};
    Reddit->new({ user_name => $t->{u}, password => $t->{p}, subreddit => 'jobs' }) #, debug => 1 });
}

sub share {
    my ($self, $job) = @_;

    ## it's not working!
    ## Reddit::_parse_link('Reddit=HASH(0x9821ed8)', '.error.BAD_CAPTCHA.field-captcha') called at /usr/local/share/perl/5.10.1/Reddit.pm line 186

    my $config = $self->config;
    my @subreddit = ('jobs');
    my ($id, $link) = $self->reddit->submit_link( $job->title, $config->{sites}->{main} . $job->url );
    my $st = $id ? 1 : 0;
    $self->log_debug("# added " . $job->url . " $st as $link");

    return $st;
}

__PACKAGE__->meta->make_immutable;

1;