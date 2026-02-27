#!/usr/bin/env bash
set -euo pipefail

mapfile -t pubspecs < <(git ls-files '*pubspec.yaml')

if [[ ${#pubspecs[@]} -eq 0 ]]; then
  exit 0
fi

perl - "${pubspecs[@]}" <<'PERL'
use strict;
use warnings;

my $violations = 0;

for my $file (@ARGV) {
  open my $fh, '<', $file or die "Failed to read $file: $!";
  my @lines = <$fh>;
  close $fh;

  my $section = '';
  for (my $i = 0; $i < @lines; $i++) {
    chomp(my $line = $lines[$i]);

    if ($line =~ /^([a-z_]+):\s*$/) {
      $section = $1;
      next;
    }

    next unless $section =~ /^(dependencies|dev_dependencies|dependency_overrides)$/;
    next unless $line =~ /^  (solana_kit[\w]*|codama_renderers_solana_kit_dart):(?:\s*(.*))?$/;

    my $name = $1;
    my $value = defined $2 ? $2 : '';

    # Allow explicit inline map form.
    if ($value =~ /^\{\s*workspace:\s*true\s*\}\s*$/) {
      next;
    }

    # Allow nested form:
    #   package_name:
    #     workspace: true
    if ($value =~ /^\s*$/) {
      my $next = $lines[$i + 1] // '';
      $next =~ s/\R\z//;
      if ($next =~ /^    workspace:\s*true\s*$/) {
        next;
      }
    }

    print "$file:" . ($i + 1) . " internal dependency '$name' must use workspace: true\n";
    $violations = 1;
  }
}

exit($violations);
PERL
