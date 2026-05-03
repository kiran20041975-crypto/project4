const express = require("express");
const mongoose = require("mongoose");
const axios = require("axios");

const app = express();
app.use(express.json());

// ✅ Env variables
const MONGO_URL = process.env.MONGO_URL || "mongodb://mongo-order:27017/orders";
const PORT = process.env.PORT || 3003;

// ✅ Model
const Order = mongoose.model("Order", {
  productId: String,
  quantity: Number,
  status: String
});

// ✅ Create order
app.post("/orders", async (req, res) => {
  try {
    const { productId, quantity } = req.body;

    // 🔍 Check product exists
    const response = await axios.get("http://product-service:3002/products");
    const products = response.data;

    const product = products.find(p => p._id === productId);

    if (!product) {
      return res.status(404).send("Product not found");
    }

    // 📝 Create order
    const order = new Order({
      productId,
      quantity,
      status: "PENDING"
    });

    await order.save();

    // 💳 Call payment service
    await axios.post("http://payment-service:3004/pay", {
      orderId: order._id
    });

    res.send(order);

  } catch (err) {
    console.error(err.message);
    res.status(500).send("Error creating order");
  }
});

// ✅ Get orders
app.get("/orders", async (req, res) => {
  try {
    const orders = await Order.find();
    res.send(orders);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// ✅ Health check
app.get("/", (req, res) => {
  res.send("Order Service is running");
});

// ✅ Start only after DB connection
mongoose.connect(MONGO_URL)
  .then(() => {
    console.log("MongoDB connected");

    app.listen(PORT, () => {
      console.log(`Order service running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error("MongoDB connection error:", err);
  });