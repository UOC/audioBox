# -*- encoding : utf-8 -*-
require 'rubygems'
require 'test/unit'
require 'ostruct'
require 'dropbox'
require "#{File.dirname(__FILE__)}/../lib/dummy_dropbox.rb"

class DummyDropboxTest < Test::Unit::TestCase
  def setup
  s = 'd332563ba920d5b08d5bb82b65faecf053f0d53e0087ed45e964e26be4e48ed866afb64b42db3e678acce2027cd98d8e13638bcc6769a60b50fdad1374333094'
    @session = Dropbox::UocSession.new('key', 'secret',{:campus_id => s  })
  end

  def test_session
    assert_equal( "#<Dropbox::UocSession dummy key consumer (authorized)>", @session.inspect )
  end

  def test_download
    assert_equal( "File 1", @session.download( '/English Vocabulary.txt' ) )
  end

  def test_metadata
    assert( @session.metadata( '' ).directory? )
    assert( @session.metadata( '/probes' ).directory? )
  end

  def test_list
    assert_equal(['/file1.txt', '/folder1'], @session.list('').map{ |e| e.path } )
    assert_equal(['folder1/file2.txt', 'folder1/file3.txt'], @session.list('folder1').map{ |e| e.path } )
  end

  def test_create_folder
    FileUtils.rm_r( "#{DummyDropbox.root_path}/tmp_folder" )  if File.exists?( "#{DummyDropbox.root_path}/tmp_folder" )
    metadata = @session.create_folder '/tmp_folder'
    assert( File.directory?( "#{DummyDropbox.root_path}/tmp_folder" ) )
    assert( metadata.directory? )

    FileUtils.rm_r( "#{DummyDropbox.root_path}/tmp_folder" )
  end

  def test_upload
    FileUtils.rm_r( "#{DummyDropbox.root_path}/file.txt" )  if File.exists?( "#{DummyDropbox.root_path}/file.txt" )
    metadata = @session.upload( "#{File.dirname(__FILE__)}/fixtures/file.txt", '/' )
    assert_equal(
      File.read( "#{File.dirname(__FILE__)}/fixtures/file.txt" ),
      File.read( "#{DummyDropbox.root_path}/file.txt" )
    )
    assert( !metadata.directory? )
    FileUtils.rm_r( "#{DummyDropbox.root_path}/file.txt" )
  end
end
