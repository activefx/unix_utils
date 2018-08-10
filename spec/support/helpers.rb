module Helpers

  def assert_does_not_touch(method_id, *args)
    infile_or_srcdir = args.first
    mtime = File.mtime infile_or_srcdir
    kind = File.file?(infile_or_srcdir) ? :file : :directory
    case kind
    when :file
      checksum = UnixUtils.shasum infile_or_srcdir, 256
    when :directory
      size = UnixUtils.du infile_or_srcdir
    end
    destdir = UnixUtils.send(*([method_id] + args))
    safe_delete destdir
    expect(File.mtime(infile_or_srcdir)).to eq mtime
    case kind
    when :file
      expect(UnixUtils.shasum(infile_or_srcdir, 256)).to eq checksum
    when :directory
      expect(UnixUtils.du(infile_or_srcdir)).to eq size
    end
  end

  def assert_unpack_dir(method_id, infile)
    destdir = UnixUtils.send method_id, infile
    expect(File.directory?(destdir)).to eq true
    expect(Dir.entries(destdir)).to eq %w{ . .. hello_world.txt hello_world.xml }
    expect(File.dirname(destdir).start_with?(Dir.tmpdir)).to eq true
    safe_delete destdir
  end

  def assert_unpack_file(method_id, infile)
    outfile = UnixUtils.send method_id, infile
    expect(File.file?(outfile)).to eq true
    expect(`file #{outfile}`.chomp).to match %r{text}
    expect(File.dirname(outfile).start_with?(Dir.tmpdir)).to eq true
    safe_delete outfile
  end

  def assert_pack(method_id, infile)
    outfile = UnixUtils.send method_id, infile
    expect(File.file?(outfile)).to eq true
    expect(`file #{outfile}`.chomp).to match %r{\b#{method_id.to_s.downcase}\b}
    expect(File.dirname(outfile).start_with?(Dir.tmpdir)).to eq true
    safe_delete outfile
  end

  def safe_delete(path)
    path = File.expand_path path
    raise "Refusing to rm -rf #{path} because it's not in #{Dir.tmpdir}" unless File.dirname(path).start_with?(Dir.tmpdir)
    FileUtils.rm_rf path
  end

end

RSpec.configure do |config|
  config.include Helpers
end
