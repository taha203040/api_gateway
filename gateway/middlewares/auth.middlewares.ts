import * as jt from 'jsonwebtoken'
import { Request, Response, NextFunction } from "express";
export const authenticate = (req: Request, res: Response) => {
    try {
        const token = req.cookies.token
        if (!token) return res.status(401).json({ err: 'unauth' })
        const decoded = jt.verify(token, 'dasdfas') as jt.JwtPayload
        if (typeof decoded !== 'object' || !decoded) {
            return res.status(401).json({ error: "Unauthorized" });
        }
        req.user = decoded as any
    } catch (err) {
        console.error(err);
        return res.status(403).json({ error: "Forbidden" });
    }
}