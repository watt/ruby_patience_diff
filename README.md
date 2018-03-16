# README

## Description

A Ruby implementation of the Patience diff algorithm.

Patience Diff creates more readable diffs than other algorithms in some cases, particularly when much of the content has changed between the documents being compared. There's a great explanation and example [here][example].

Patience diff was originally written by Bram Cohen and is used in the [Bazaar][bazaar] version control system. This version is loosely based off the Python implementation in Bazaar.

[example]: http://alfedenzo.livejournal.com/170301.html
[bazaar]: http://bazaar.canonical.com/

## Installation

    $ gem install patience_diff

## Usage

### Command line:

    $ patience_diff [options] file-a file-b

Run with `--help` to see available options.

### Programmatically

Diff files to stdout:

    differ = PatienceDiff::Differ.new
    differ.diff_files("/path/to/left", "path/to/right")

Diff arrays to stdout:

    # name and timestamp metadata is optional
    differ.diff_sequences(
      left_array,
      right_array,
      left_name: left_filename,
      right_name: right_filename,
      left_timestamp: left_timestamp,
      right_timestamp: right_timestamp
    )

Manual diff processing:

    matcher = PatienceDiff::SequenceMatcher.new
    opcodes = matcher.diff_opcodes(left, right)
    opcodes.each do |(code, a_start, a_end, b_start, b_end)|
      case code
      when :equal
        puts 'Equal range:'
        puts b[b_start..b_end].map { |line| ' ' + line }
      when :delete
        puts 'Deleted:'
        puts a[a_start..a_end].map { |line| '-' + line }
      when :insert
        puts 'Inserted:'
        puts b[b_start..b_end].map { |line| '+' + line }
      end
    end

See `SequenceMatcher.rb` for documentation of diff opcodes.

## License

(The MIT License)

Copyright (c) 2012 Andrew Watt

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
