import { Router } from "express";
import express from "express";
const app = express();
app.get('/', (req, res) => {
    console.log('hello from checkout ')
    res.status(200).json({ msg: 'hi from checkout' })
})
app.get('/orders', (req, res) => {
    console.log('hello from orders ')
    res.status(200).json({ msg: 'hi from checkout' })
})
app.listen(3002, "0.0.0.0", () => {
    console.log('checkout')
})