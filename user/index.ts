import { Router } from "express";
import { login, signup } from "./user_auth";
import express from "express";
const router = Router();
router.post("/signup", signup);
router.post("/login", login);
const app = express();
app.use(express.json());
app.use("/auth", router);
app.listen(3001 , ()=>{
    console.log('user')
})
export default router;

