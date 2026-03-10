import { Router } from "express";
import { login, signup } from "./user_auth";
import express from "express";
const app = express();
const router = Router();
app.use(express.json());
router.post("/signup", signup);
router.post("/login", login);
router.get('/', (req, res) => {
    console.log('hello world ')
    res.json({ msg: "hello worl from nginx " })
})
app.use("/auth", router);
app.get('/', (req, res) => {
    console.log('hello from user ')
    res.status(200).json({ msg: 'hi from user' })
})
app.listen(3001, "0.0.0.0", () => {
    console.log('user')
})
export default router;

