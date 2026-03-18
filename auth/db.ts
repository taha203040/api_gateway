import { Pool } from "pg";

const pool = new Pool({
  // host: process.env.DB_HOST,
  host: 'user_db',
  port: 5432,
  user: 'admin',
  password: 'admin',
  database: 'users_db',
});


export default pool;