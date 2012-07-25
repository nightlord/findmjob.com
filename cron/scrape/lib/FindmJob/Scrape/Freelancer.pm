package FindmJob::Scrape::Freelancer;

## Note: Freelancer API sucks

use Moose;
use namespace::autoclean;

with 'FindmJob::Scrape::Role';

use XML::Simple 'XMLin';
use HTML::TreeBuilder;
use Try::Tiny;
use FindmJob::DateUtils 'human_to_db_datetime';
use List::Util 'shuffle';

sub run {
    my ($self) = @_;

    my $schema = $self->schema;
    my $job_rs = $schema->resultset('Freelance');
    my @urls = ('http://www.freelancer.com/rss.xml');

    # set socks proxy (Tor)
    my $config = $self->config;
    $self->ua->proxy('http', $config->{scrape}->{proxy})
        if $config->{scrape}->{proxy};

    # those urls just do it every hour, not on each 15 minutes
    my @d = localtime();
    if ($d[1] > 10 and $d[2] < 20) {
        push @urls, ('http://www.freelancer.com/rss/job_Python.xml', 'http://www.freelancer.com/rss/job_Ruby-on-Rails.xml', 'http://www.freelancer.com/rss/job_PHP.xml', 'http://www.freelancer.com/rss/job_Java.xml');
    }

    foreach my $url (@urls) {
        $self->log_debug("# get $url");
        my $resp = $self->get($url);
        my $data = XMLin($resp->decoded_content);
        foreach my $item ( @{$data->{channel}->{item}} ) {
            my $description = $item->{description};
            next if $description =~ '^N/A'; # Deleted Project or Protected Project
            next if $description =~ 'Budget: N/A';
            next if $item->{title} =~ /^Nonpublic project/; # Nonpublic project
            next if $item->{link} eq 'http://www.freelancer.com/projects/sl/1341869714.html';

            # Check budget, don't insert if budget is too low b/c those are expired soon
            # (Budget: &#36;30-&#36;250 USD, Jobs: iPhone, Mobile Phone)
            my (undef, $max_budget) = ($description =~ /\(Budget\:(.*?)(\d+)\s+(\w{3})\,\s*Jobs/);
            die $item->{link} unless $max_budget;
            next if $max_budget < 500;

            my $link = $item->{link};
            my $is_inserted = $job_rs->is_inserted_by_url($link);
            next if $is_inserted and not $self->opt_update;
            my $row = $self->on_single_page($item);
            next unless $row;
            if ( $is_inserted and $self->opt_update ) {
                $job_rs->update_job($row);
            } else {
                $job_rs->create_job($row);
            }
        }
    }
}

sub on_single_page {
    my ($self, $item) = @_;

    my $link = $item->{link};
    $self->log_debug("# get $link");
    my $resp = $self->get($link); sleep 3;
    return unless $resp->is_success;
    return unless $resp->decoded_content =~ /\<\/html\>/i;
    my $tree = HTML::TreeBuilder->new_from_content($resp->decoded_content);
 #   try {
        my $data;
        my $title = $tree->look_down(_tag => 'h1')->as_trimmed_text;
        my $ns_description = $tree->look_down(_tag => 'div', class => 'ns_description');

        my %skill_urls;
        foreach my $item_r ($ns_description->content_refs_list) {
            next unless ref $$item_r; # we don't change plain text
            my $h = $$item_r;
            my $tag = $h->{_tag};
            if ($tag eq 'ul' and $h->attr('class') and $h->attr('class') eq 'ns_specifications') {
                $h->replace_with_content( $h->as_trimmed_text );
            }
            if ($tag eq 'div' and $h->attr('class') and $h->attr('class') eq 'tags') {
                $h->detach();
            }
            if ($tag eq 'a' and $h->attr('href') and $h->attr('href') =~ '../jobs/') {
                 my ($cw) = ($h->attr('href') =~ '/jobs/([^\/]+)');
                 $skill_urls{ $h->as_trimmed_text } = $cw;
                 $h->replace_with_content( $h->as_trimmed_text );
            }
        }

        my $desc = $self->format_tree_text($ns_description);

        my @tags = ('freelancer', 'freelance');
        push @tags, $self->get_extra_tags_from_desc($title);
        push @tags, $self->get_extra_tags_from_desc($desc);
        push @tags, keys %skill_urls;

        ## better out
        $desc =~ s/(ID|Type|Budget)\:\s+/$1\: /isg;

        my $row = {
            source_url => $link,
            title => $title,
            contact   => '',
            posted_at => human_to_db_datetime($item->{'pubDate'}),
            description => $desc,
            location => 'Anywhere',
            type  => '',
            extra => '',
            tags  => \@tags
        };
#    } catch {
#        $self->log_fatal($_);
#    }
    $tree = $tree->delete;

    return $row;
}

__PACKAGE__->meta->make_immutable;

1;