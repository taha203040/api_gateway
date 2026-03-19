import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import pool from './db';
import { Request, Response } from "express";

export const signup = async (req: Request, res: Response) => {
  try {
    const { username, email, password } = req.body;

    const userExists = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (userExists.rows.length > 0) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      "INSERT INTO users (username, email, password) VALUES ($1,$2,$3) RETURNING id, username, email",
      [username, email, hashedPassword]
    );

    res.status(201).json({
      message: "User created",
      user: result.rows[0],
    });
  } catch (error) {
    res.status(500).json({ error: "Internal server error", err: error });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const user = result.rows[0];

    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).json({ message: "Invalid credentials" });
    }
    console.log(`${process.env.JWT_SECRET}`)
    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email,
      },
      'process.env.JWT_SECRET' as string,
      {
        expiresIn: "1h",
      }
    );
    res.json({
      message: "Login success",
      token,
    });
  } catch (error) {
    res.status(500).json({ error: "Internal server error", errr: error, tkn: `${process.env.JWT_SECRET}` });
  }
};
export const verifyToken = (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.sendStatus(401);
    }
    const token = authHeader.split(" ")[1] as string
    if (!token) res.status(400)
    const decoded = jwt.verify(token, 'process.env.JWT_SECRET' as  string);
    (req as any).user = decoded;
    console.log('decoded', decoded)
    console.log(`${req.headers.authorization}`)
    res.status(200).json({ msg: 'verifyed' })
    // next();
  } catch (error) {
    console.log('err', error)
    return res.status(401).json({ message: "Invalid or expired token", err: error, er: `${req.headers.authorization}` });
  }
};