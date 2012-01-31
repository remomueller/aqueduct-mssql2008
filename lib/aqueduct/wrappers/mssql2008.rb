require 'aqueduct'
# require 'dbi', moved into functions since the associated Rake task was colliding with ActiveModel deprecate method and causing test failure, potentially remove dependency on dbi in future.

module Aqueduct
  module Wrappers
    class Mssql2008
      include Aqueduct::Wrapper

      def sql_codes
        { text: 'VARCHAR(MAX)', numeric: 'NUMERIC', open: '[', close: ']' }
      end

      def connect
        require 'dbi'
        @db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
      end

      def disconnect
        @db_connection.disconnect if @db_connection
        true
      end

      def query(sql_statement)
        results = []
        results = @db_connection.execute(sql_statement) if @db_connection
        temp_array = []
        results.each {|row| temp_array << row.to_a}
        results = temp_array
        [results, results.size]
      end

      def connected?
        result = false
        error = ''
        begin
          require 'dbi'
          db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
        rescue => e
          error = "Connection Error: #{e.inspect}" # { }"#{e.errno}: #{e.error}"
        ensure
          result = true if db_connection
          db_connection.disconnect if db_connection
        end
        { result: result, error: error }
      end

      def get_table_metadata
        result = {}
        error = ''
        begin
          require 'dbi'
          db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
          if db_connection
            tables = []
            results = db_connection.execute('select * from sys.Tables')
            results.each do |row|
              tables << row[0]
            end

            results = db_connection.execute('select * from sys.Views')
            results.each do |row|
              tables << row[0]
            end

            tables.sort{|table_a, table_b| table_a.downcase <=> table_b.downcase}.each do |my_table|
              results = db_connection.columns(my_table)
              columns = []
              results.each do |row|
                columns << {column: row[:name], datatype: row[:type_name]}
              end
              result[my_table] = columns.sort{|a,b| a[:column].downcase <=> b[:column].downcase}
            end
          end
        rescue => e
          error = e.inspect
        ensure
          db_connection.disconnect if db_connection
        end
        { result: result, error: error }
      end

      def tables
        tables = []
        error = ''
        begin
          require 'dbi'
          db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
          if db_connection
            results = db_connection.execute('select * from sys.Tables')
            results.each do |row|
              tables << row[0]
            end
            results = db_connection.execute('select * from sys.Views')
            results.each do |row|
              tables << row[0]
            end
          end
        rescue => e
          error = e.inspect
        ensure
          db_connection.disconnect if db_connection
        end
        { result: tables, error: error }
      end

      def table_columns(table)
        columns = []
        error = ''
        begin
          require 'dbi'
          db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
          if db_connection
            results = db_connection.columns(table)
            results.each { |row| columns << { column: row[:name], datatype: row[:type_name] } }
          end
        rescue => e
          error = "Error retrieving column information. Please make sure that this database is configured correctly. #{e.inspect}"
        ensure
          db_connection.disconnect if db_connection
        end
        { columns: columns, error: error }
      end

      def get_all_values_for_column(table, column)
        values = []
        error = ''
        begin
          require 'dbi'
          db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
          if db_connection
            column_found = db_connection.columns(table).collect{|c| c[:name]}.include?(column)

            if not column_found
              result += " <i>#{column}</i> does not exist in <i>#{@source.database}.#{table}</i>"
            else
              results = db_connection.execute("SELECT [#{column}] FROM #{table};")
              results.each do |row|
                value = row.first
                if value.class != String and value.respond_to?('round') and value.round == value
                  values << value.round
                else
                  values << value
                end
              end
            end
          end
        rescue => e
          error = "Get All Values For Column Error: #{e}"
        ensure
          if db_connection
            db_connection.disconnect
          else
            error += " unable to connect to <i>#{@source.name}</i>"
          end
        end
        { values: values, error: error }
      end

      def column_values(table, column)
        error = ''
        result = []
        begin
          require 'dbi'
          db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
          column_found = db_connection.columns(table).collect{|c| c[:name]}.include?(column)

          if column_found
            results = db_connection.execute("SELECT [#{column}] as 'column', count(*) FROM #{table} GROUP BY [#{column}];")
            results.each do |row|
              if row['column'].class != String and row['column'].respond_to?('round') and row['column'].round == row['column']
                result << row['column'].round
              else
                result << row['column']
              end
            end
          end
        rescue => e
          error = "Error: #{e.inspect}"
        ensure
          db_connection.disconnect if db_connection
        end
        { result: result, error: error }
      end

      def count(query_concepts, conditions, tables, join_conditions, concept_to_count)
        result = 0
        error = ''
        sql_conditions = ''
        begin
          t = Time.now
          if tables.size > 0
            sql_conditions = "SELECT count(#{concept_to_count ? 'DISTINCT ' + concept_to_count : '*'}) as record_count FROM #{tables.join(', ')} WHERE #{join_conditions.join(' and ')}#{' and ' unless join_conditions.blank?}#{conditions}"
            Rails.logger.info sql_conditions
            require 'dbi'
            db_connection = DBI.connect("DBI:ODBC:#{@source.database}", @source.username, @source.password)
            if db_connection
              results = db_connection.execute(sql_conditions)
              results.each do |row|
                result = row['record_count']
              end
            end
          else
            error = "Database [#{@source.name}] Error: No tables for concepts. Database not fully mapped."
          end
        rescue => e
          error = "Database [#{@source.name}] Error: #{e}"
        ensure
          db_connection.disconnect if db_connection
        end
        { result: result, error: error, sql_conditions: sql_conditions }
      end
    end
  end
end