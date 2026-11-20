-- Runs once on an empty MySQL volume. The app user may create and drop only this project's databases
-- (development and test), so bin/rails db:prepare and the test suite work without the root account.
GRANT ALL PRIVILEGES ON `newerp\_ruby\_%`.* TO 'newerp'@'%';
FLUSH PRIVILEGES;
