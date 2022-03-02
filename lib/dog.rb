class Dog
    attr_accessor :name, :breed, :id
    def initialize(id: nil, name:, breed:)
        @name = name 
        @breed = breed 
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT);
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL 
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES(?, ?);
        SQL
        
        sql_query = <<-SQL
            SELECT id FROM dogs WHERE name = ? AND breed = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        DB[:conn].execute(sql_query, self.name, self.breed).map do |dog|
            @id = dog[0]
        end
        self
    end

    def self.create(name:, breed:)
        instance = self.new(name: name, breed: breed)
        instance.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = <<-SQL
            SELECT * FROM dogs
        SQL
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?;
        SQL

        something = DB[:conn].execute(sql, name, breed).map do |instance|
            self.new_from_db(instance)
        end.first

        if something
            something
        else
            self.create(name: name, breed: breed)
        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
    end

end
