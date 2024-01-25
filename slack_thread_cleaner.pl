use strict;
use warnings;

# テキストファイルのパス
my $file_path = 'messages.txt';

# ファイルを前から読み込む
open(my $fh, '<', $file_path) or die "ファイルを開けません: $!";
my @lines = <$fh>;
close($fh);

my @processed_lines;
my %to_delete = ();

for (my $i = 0; $i < @lines; $i++) {
    if ($lines[$i] =~ /ago/) {
        $to_delete{$i} = 1;
        $to_delete{$i - 1} = 1 if $i > 0;
    }

    # 絵文字のみの行と、直後に数字のみの行が続く場合を特定
    if ($lines[$i] =~ /^:\w+:$/ && $i < $#lines && $lines[$i + 1] =~ /^\d+$/) {
        $to_delete{$i} = 1;
        $to_delete{$i + 1} = 1;
    }
}

# 特定された行を除去する
for (my $i = 0; $i < @lines; $i++) {
    next if exists $to_delete{$i};  # 削除対象の行はスキップ
    my $line = $lines[$i];
    chomp $line;

    next if $line eq "Thread" || $line =~ /replies/ || $line =~ /^\s*$/;

    push @processed_lines, $line;
}

# 処理した内容を元のファイルに書き込む
open(my $fh_write, '>', $file_path) or die "ファイルを開けません: $!";
foreach my $line (@processed_lines) {
    print $fh_write "$line\n";
}
close($fh_write);
