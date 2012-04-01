package FindmJob::Schema::ResultSet::Tag;

use Moose;
use namespace::autoclean;
extends 'FindmJob::Schema::ResultSet';

use FindmJob::Utils 'uuid';

sub get_id_by_text {
    my ($self, $text) = @_;

    my $row = $self->search( { text => $text } )->first;
    return $row->id if $row;
    $row = $self->create( { text => $text } );
    return $row->id;
}

1;