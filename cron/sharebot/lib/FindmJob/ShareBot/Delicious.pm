package FindmJob::ShareBot::Delicious;

use Moo;
with 'FindmJob::ShareBot::Role';

use Net::Delicious;

has 'delicious' => ( is => 'lazy' );
sub _build_delicious {
    my $self = shift;
    my $config = $self->config;
    my $t = $config->{share}->{Delicious};
    Net::Delicious->new({ user => $t->{u}, pswd => $t->{p} }) #, debug => 1 });
}

sub share {
    my ($self, $job) = @_;

    my @tags = @{ $job->tags };
    @tags = map { $_->{text} } @tags;
    @tags = $self->remove_useless_tags(@tags);
    push @tags, 'findmjob', 'job';

    my $config = $self->config;
    my $st = $self->delicious->add_post( {
        url => $config->{sites}->{main} . $job->url,
        title => $job->title,
        description => $job->title, # substr($job->description, 0, 255) . '...',
        tags  => join(', ', @tags),
        shared => 'yes'
    } );
    $self->log_debug("# added " . $job->url . " $st");

    return $st;
}

1;