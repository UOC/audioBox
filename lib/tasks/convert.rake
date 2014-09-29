  desc "convert a latin1 database with utf8 data into proper utf8"
  task :convert_to_utf8 => :environment do
    puts Time.now
    dryrun = ENV['DOIT'] != '1'
    conn = ActiveRecord::Base.connection
    if dryrun
      def conn.run_sql(sql)
        puts(sql)
      end
    else
      def conn.run_sql(sql)
        puts(sql)
        execute(sql)
      end
    end

    conn.run_sql "ALTER DATABASE uocBox CHARACTER SET utf8 collate utf8_unicode_ci"

    # Don't covert views
    VIEWS = /(view|_v$)/
    big = []

    # These are table_name => model_class mappings that aren't rails standard or
    # tables that we don't wish to convert (table_name => true).
    mapping = { :schema_migrations => true,
    :groups_users => true
    }.with_indifferent_access
    tables = (conn.tables - big).select { |tbl| tbl !~ VIEWS }
    puts "Converting #{tables.inspect}"

    #(tables - big).each do |tbl|
    tables.each do |tbl|
      a = ['CHARACTER SET utf8 COLLATE utf8_unicode_ci']
      b = []
      model = mapping[tbl] || tbl.to_s.classify.constantize
      model.columns.each do |col|
        type = col.sql_type

        nullable = col.null ? '' : ' NOT NULL'
        default = col.default ? " DEFAULT '#{col.default}'" : ''

        case type
        when /varchar/
          a << "CHANGE #{col.name} #{col.name} VARBINARY(#{col.limit})"
          b << "CHANGE #{col.name} #{col.name} VARCHAR(#{col.limit}) CHARACTER SET utf8 COLLATE utf8_unicode_ci#{nullable}#{default}"
        when /text/
          a << "CHANGE #{col.name} #{col.name} BLOB"
          b << "CHANGE #{col.name} #{col.name} TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci#{nullable}#{default}"
        end
      end unless model == true

      conn.run_sql "ALTER TABLE #{tbl} #{a.join(', ')}"
      conn.run_sql "ALTER TABLE #{tbl} #{b.join(', ')}" if b.present?
    end

    puts Time.now
    puts 'Done!'
  end
