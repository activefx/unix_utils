require 'spec_helper'

RSpec.describe UnixUtils do

  specify { expect(described_class::VERSION).not_to be_nil }

  before(:each) do
    @old_pwd = Dir.pwd
    Dir.chdir File.expand_path('../target', __FILE__)
  end

  after(:each) do
    Dir.chdir @old_pwd
  end

  context "errors" do

    it "gets printed to stderr" do
      expect { UnixUtils.unzip(__FILE__) }
        .to raise_error RuntimeError, %r{End-of-central-directory signature not found}
    end

  end

  context ".curl" do

    it "downloads to a temp file" do
      outfile = UnixUtils.curl('http://example.org/')
      expect(File.read(outfile)).to match %r{Example Domain}i
      safe_delete outfile
    end

    it "deals safely with local files" do
      expect(UnixUtils.curl_s('utf 8.txt')).to include 'Hola, ¿cómo estás?'
      expect(UnixUtils.curl_s(File.expand_path('utf 8.txt'))).to include 'Hola, ¿cómo estás?'
      expect(UnixUtils.curl_s("file://#{File.expand_path('utf 8.txt')}")).to include 'Hola, ¿cómo estás?'
    end

  end

  context ".shasum" do

    it "checksums a file with SHA-1" do
      expect(UnixUtils.shasum('a directory.zip', 1))
        .to eq 'c0abb36c923ed7bf87ebb8d7097cb8e264e528d2'
    end

    it "checksums a file with SHA-256" do
      expect(UnixUtils.shasum('a directory.zip', 256))
        .to eq '661af2b7b0993088263228b071b649a88d82a6a655562162c32307d1e127f27a'
    end

    it "works just as well with absolute paths" do
      target_path = File.join(Dir.pwd, 'a directory.zip')
      Dir.chdir('/') do
        expect(UnixUtils.shasum(target_path, 256))
          .to eq '661af2b7b0993088263228b071b649a88d82a6a655562162c32307d1e127f27a'
      end
    end

  end

  context ".md5sum" do

    it "checksums a file" do
      expect(UnixUtils.md5sum('a directory.zip'))
        .to eq 'd6e15da798ae19551da6c49ec09afaef'
    end

  end

  context ".du" do

    it "calculates the size of a directory in bytes" do
      expect(UnixUtils.du('a directory')).to eq 8
    end

  end

  context ".unzip" do

    let(:infile) { 'a directory.zip' }
    let(:anonymous_infile) { 'a directory really a z i p shh' }

    it "unpacks a DIRECTORY located in the tmp directory" do
      assert_unpack_dir :unzip, infile
    end

    it "accepts unsemantic filenames" do
      assert_unpack_dir :unzip, anonymous_infile
    end

    it "does not touch the infile" do
      assert_does_not_touch :unzip, infile
    end

  end

  context ".untar" do

    let(:infile) { 'a directory.tar' }
    let(:anonymous_infile) { 'a directory really a t a r shh' }

    it "unpacks a DIRECTORY located in the tmp directory" do
      assert_unpack_dir :untar, infile
    end

    it "accepts unsemantic filenames" do
      assert_unpack_dir :untar, anonymous_infile
    end

    it "does not touch the infile" do
      assert_does_not_touch :untar, infile
    end

  end

  context ".bunzip2" do

    let(:infile) { 'a file.bz2' }
    let(:anonymous_infile) { 'file really a b z 2 shh' }

    it "unpacks a FILE located in the tmp directory" do
      assert_unpack_file :bunzip2, infile
    end

    it "accepts unsemantic filenames" do
      assert_unpack_file :bunzip2, anonymous_infile
    end

    it "does not touch the infile" do
      assert_does_not_touch :bunzip2, infile
    end

  end

  context ".gunzip" do

    let(:infile) { 'a file.gz' }
    let(:anonymous_infile) { 'file really a g z shh' }

    it "unpacks a FILE located in the tmp directory" do
      assert_unpack_file :gunzip, infile
    end

    it "accepts unsemantic filenames" do
      assert_unpack_file :gunzip, anonymous_infile
    end

    it "does not touch the infile" do
      assert_does_not_touch :gunzip, infile
    end

  end

  context ".bzip2" do

    let(:infile) { 'a directory.tar' }

    it "packs a FILE to a FILE in the tmp directory" do
      assert_pack :bzip2, infile
    end

    it "does not touch the infile" do
      assert_does_not_touch :bzip2, infile
    end

    it "sticks on a useful extension" do
      outfile = UnixUtils.bzip2 infile
      expect(File.extname(outfile)).to eq '.bz2'
      safe_delete outfile
    end

  end

  context ".gzip" do

    let(:infile) { 'a directory.tar' }

    it "packs a FILE to a FILE in the tmp directory" do
      assert_pack :gzip, infile
    end

    it "does not touch the infile" do
      assert_does_not_touch :gzip, infile
    end

    it "sticks on a useful extension" do
      outfile = UnixUtils.gzip infile
      expect(File.extname(outfile)).to eq '.gz'
      safe_delete outfile
    end

  end

  context ".zip" do

    let(:srcdir) { 'a directory' }

    it "packs a DIRECTORY to a FILE in the tmp directory" do
      assert_pack :zip, srcdir
    end

    it "does not touch the infile" do
      assert_does_not_touch :zip, srcdir
    end

    it "sticks on a useful extension" do
      outfile = UnixUtils.zip srcdir
      expect(File.extname(outfile)).to eq '.zip'
      safe_delete outfile
    end

  end

  context ".tar" do

    let(:srcdir) { 'a directory' }

    it "packs a DIRECTORY to a FILE in the tmp directory" do
      assert_pack :tar, srcdir
    end

    it "does not touch the infile" do
      assert_does_not_touch :tar, srcdir
    end

    it "sticks on a useful extension" do
      outfile = UnixUtils.tar srcdir
      expect(File.extname(outfile)).to eq '.tar'
      safe_delete outfile
    end

  end

  context ".perl" do

    before(:each) do
      @f = Tempfile.new('perl.txt')
      @f.write "badWord\n"*100
      @f.flush
      @infile = @f.path
    end

    after(:each) do
      @f.close
    end

    it "processes a file" do
      outfile = UnixUtils.perl(@infile, 's/bad/good/g')
      expect(File.read(outfile)).to eq "goodWord\n"*100
      safe_delete outfile
    end

    it "does not touch the infile" do
      assert_does_not_touch :perl, @infile, 's/bad/good/g'
    end

    it "keeps the original extname" do
      outfile = UnixUtils.perl(@infile, 's/bad/good/g')
      expect(File.extname(outfile)).to eq File.extname(@infile)
      safe_delete outfile
    end

  end

  context ".awk" do

    before(:each) do
      @f = Tempfile.new('awk.txt')
      @f.write "badWord\n"*100
      @f.flush
      @infile = @f.path
    end

    after(:each) do
      @f.close
    end

    it "processes a file" do
      outfile = UnixUtils.awk(@infile, '{gsub(/bad/, "good"); print}')
      expect(File.read(outfile)).to eq "goodWord\n"*100
      safe_delete outfile
    end

    it "does not touch the infile" do
      assert_does_not_touch :awk, @infile, '{gsub(/bad/, "good"); print}'
    end

    it "keeps the original extname" do
      outfile = UnixUtils.awk(@infile, '{gsub(/bad/, "good"); print}')
      expect(File.extname(outfile)).to eq File.extname(@infile)
      safe_delete outfile
    end

  end

  context ".unix2dos" do

    before(:each) do
      @f = Tempfile.new('unix2dos.txt')
      @f.write "unix\n"*5_000
      @f.write "dos\r\n"*5_000
      @f.flush
      @infile = @f.path
    end

    after(:each) do
      @f.close
    end

    it "converts newlines" do
      outfile = UnixUtils.unix2dos @infile
      expect(File.read(outfile)).to eq("unix\r\n"*5_000 + "dos\r\n"*5_000)
      safe_delete outfile
    end

  end

  context ".dos2unix" do

    before(:each) do
      @f = Tempfile.new('dos2unix.txt')
      @f.write "dos\r\n"*5
      @f.write "unix\n"*5
      @f.flush
      @infile = @f.path
    end

    after(:each) do
      @f.close
    end

    it "converts newlines" do
      outfile = UnixUtils.dos2unix @infile
      expect(File.read(outfile)).to eq("dos\n"*5 + "unix\n"*5)
      safe_delete outfile
    end

  end

  context ".wc" do

    before(:each) do
      @f = Tempfile.new('wc.txt')
      @f.write "dos line\r\n"*50_000
      @f.write "unix line\n"*50_000
      @f.flush
      @infile = @f.path
    end

    after(:each) do
      @f.close
    end

    it "counts lines, words, and bytes" do
      expect(UnixUtils.wc(@infile)).to eq [50_000+50_000, 100_000+100_000, 500_000+500_000]
    end

  end

  context ".sed" do

    before do
      @f = Tempfile.new('sed.txt')
      @f.write "badWord\n"*100
      @f.flush
      @infile = @f.path
    end

    after do
      @f.close
    end

    it "processes a file" do
      outfile = UnixUtils.sed(@infile, 's/bad/good/g')
      expect(File.read(outfile)).to eq "goodWord\n"*100
      safe_delete outfile
    end

    it "does not touch the infile" do
      assert_does_not_touch :sed, @infile, 's/bad/good/g'
    end

    it "keeps the original extname" do
      outfile = UnixUtils.sed(@infile, 's/bad/good/g')
      expect(File.extname(outfile)).to eq File.extname(@infile)
      safe_delete outfile
    end

  end

  context ".tail" do

    before do
      @a2z = ('a'..'z').to_a
      @f = Tempfile.new('tail.txt')
      @f.write @a2z.join("\n")
      @f.flush
      @infile = @f.path
    end

    after do
      @f.close
    end

    it "gets last three lines" do
      outfile = UnixUtils.tail(@infile, 3)
      expect(File.read(outfile)).to eq @a2z.last(3).join("\n")
      safe_delete outfile
    end

    it "gets trailing lines starting with the third line (inclusive)" do
      outfile = UnixUtils.tail(@infile, "+3")
      expect(File.read(outfile)).to eq @a2z[2..-1].join("\n")
      safe_delete outfile
    end

    it "has a related tail_s method" do
      str = UnixUtils.tail_s(@infile, 3)
      expect(str).to eq @a2z.last(3).join("\n")
    end

  end

  context ".head" do

    before do
      @a2z = ('a'..'z').to_a
      @f = Tempfile.new('head.txt')
      @f.write @a2z.join("\n")
      @f.flush
      @infile = @f.path
    end

    after do
      @f.close
    end

    it "gets first three lines" do
      outfile = UnixUtils.head(@infile, 3)
      expect(File.read(outfile)).to eq(@a2z.first(3).join("\n") + "\n")
      safe_delete outfile
    end

    it "has a related head_s method" do
      str = UnixUtils.head_s(@infile, 3)
      expect(str).to eq(@a2z.first(3).join("\n") + "\n")
    end

  end

  context ".cut" do

    before do
      @a2z = ('a'..'z').to_a
      @f = Tempfile.new('cut.txt')
      10.times do
        @f.write(@a2z.join + "\n")
      end
      @f.flush
      @infile = @f.path
    end

    after do
      @f.close
    end

    it "cuts out character positions" do
      outfile = UnixUtils.cut(@infile, "1,12,13,15,19,20")
      almosts = (0..9).map { |i| "almost" }.join("\n") + "\n"
      expect(File.read(outfile)).to eq almosts
      safe_delete outfile
    end

    it "cuts out character ranges (inclusive)" do
      outfile = UnixUtils.cut(@infile, "3-6")
      cdefs = (0..9).map { |i| "cdef" }.join("\n") + "\n"
      expect(File.read(outfile)).to eq cdefs
      safe_delete outfile
    end

  end

  context ".iconv" do

    it "converts files from utf-8 to latin1" do
      outfile = UnixUtils.iconv("utf 8.txt", "ISO-8859-1", "UTF-8")
      expect(UnixUtils.md5sum(outfile)).to eq UnixUtils.md5sum("iso 8859 1.txt")
      safe_delete outfile
    end

    it "converts files from latin1 to utf-8" do
      outfile = UnixUtils.iconv("iso 8859 1.txt", "UTF-8", "ISO-8859-1")
      expect(UnixUtils.md5sum(outfile)).to eq UnixUtils.md5sum("utf 8.txt")
      safe_delete outfile
    end

  end

  context ".tmp_path" do

    it "includes basename of ancestor" do
      expect(UnixUtils.tmp_path("dirname1/dirname2/basename.extname")).to include 'basename'
    end

    it "includes extname of ancestor" do
      expect(UnixUtils.tmp_path("dirname1/dirname2/basename.extname")).to include 'extname'
    end

    it "optionally appends extname" do
      expect(File.extname(UnixUtils.tmp_path("dirname1/dirname2/basename.extname", '.foobar')))
        .to eq '.foobar'
    end

    it "doesn't create excessively long filenames" do
      100.times { expect(File.basename(UnixUtils.tmp_path("a"*5000)).length).to eq(255) }
    end

    it "doesn't include directory part of ancestor" do
      expect(UnixUtils.tmp_path("dirname1/dirname2/basename.extname")).not_to include 'dirname1'
    end

    it "includes unix_utils part only once" do
      one = UnixUtils.tmp_path('basename.extname')
      expect(File.basename(one).start_with?('unix_utils')).to eq true
      expect(one.scan(/unix_utils/).length).to eq 1
      again = UnixUtils.tmp_path(one)
      expect(File.basename(again).start_with?('unix_utils')).to eq true
      expect(again.scan(/unix_utils/).length).to eq 1
      and_again = UnixUtils.tmp_path(again)
      expect(File.basename(and_again).start_with?('unix_utils')).to eq true
      expect(and_again.scan(/unix_utils/).length).to eq 1
      expect(and_again).to include('basename.extname')
    end

  end

  # not really for public consumption
  context ".spawn" do

    before do
      @f = Tempfile.new('spawn.txt')
      @f.write "dos line\r\n"*50_000
      @f.write "unix line\n"*50_000
      @f.flush
      @infile = @f.path
    end

    after do
      @f.close
    end

    it "reads and writes everything" do
      wc_output = UnixUtils.spawn(['wc', @infile])
      expect(wc_output.strip.split(/\s+/)[0..2].map { |s| s.to_i })
        .to eq [50_000+50_000, 100_000+100_000, 500_000+500_000]
    end

  end

end
