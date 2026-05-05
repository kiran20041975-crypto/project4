const express = require("express");
const mongoose = require("mongoose");

const app = express();
app.use(express.json());

// ✅ Use env variable
const MONGO_URL = process.env.MONGO_URL || "mongodb://mongo-product:27017/products";
const PORT = process.env.PORT || 3002;

// ✅ Schema
const Product = mongoose.model("Product", {
  name: String,
  price: Number
});

// ✅ Routes

// Add product
app.post("/products", async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.send(product);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Get products
app.get("/products", async (req, res) => {
  try {
    const products = await Product.find();
    res.send(products);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Health check
app.get("/", (req, res) => {
  res.send("Product Service is running");
});

// ✅ Connect DB then start server
mongoose.connect(MONGO_URL)
  .then(() => {
    console.log("MongoDB connected");

    app.listen(PORT, () => {
      console.log(`Product service running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error("MongoDB connection error:", err);
  });