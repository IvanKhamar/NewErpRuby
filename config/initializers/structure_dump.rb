# The app's MySQL user has no PROCESS privilege, which mysqldump needs only for tablespace info.
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ["--no-tablespaces"]
