use utf8;
package FindmJob::Schema::Result::Subscriber;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FindmJob::Schema::Result::Subscriber

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<subscriber>

=cut

__PACKAGE__->table("subscriber");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 22

=head2 email

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 frm

  data_type: 'varchar'
  is_nullable: 0
  size: 12

=head2 keyword

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 loc

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 frequency_days

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 0

=head2 created_at

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 last_sent

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 is_active

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 22 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "frm",
  { data_type => "varchar", is_nullable => 0, size => 12 },
  "keyword",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "loc",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "frequency_days",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "created_at",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "last_sent",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "is_active",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<ek>

=over 4

=item * L</email>

=item * L</keyword>

=back

=cut

__PACKAGE__->add_unique_constraint("ek", ["email", "keyword"]);


# Created by DBIx::Class::Schema::Loader v0.07019 @ 2012-04-24 19:50:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j5Mu3IzcKXZwwGy6R3nvTA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
