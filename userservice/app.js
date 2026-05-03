const express = require("express");
const mongoose = require("mongoose");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");

const app = express();
app.use(express.json());

// ✅ Use env variable (fallback also added)
const MONGO_URL = process.env.MONGO_URL || "mongodb://mongo-user:27017/users";
const PORT = process.env.PORT || 3001;

// ✅ User Schema
const User = mongoose.model("User", {
  email: String,
  password: String
});

// ✅ Routes

// Register
app.post("/register", async (req, res) => {
  try {
    const hashed = await bcrypt.hash(req.body.password, 10);
    const user = new User({
      email: req.body.email,
      password: hashed
    });

    await user.save();
    res.send("User registered");
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Login
app.post("/login", async (req, res) => {
  try {
    const user = await User.findOne({ email: req.body.email });
    if (!user) return res.status(400).send("User not found");

    const valid = await bcrypt.compare(req.body.password, user.password);
    if (!valid) return res.status(400).send("Invalid password");

    const token = jwt.sign({ id: user._id }, "secret");
    res.json({ token });
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Health check (VERY useful)
app.get("/", (req, res) => {
  res.send("User Service is running");
});

// ✅ Connect DB then start server
mongoose.connect(MONGO_URL)
  .then(() => {
    console.log("MongoDB connected");

    app.listen(PORT, () => {
      console.log(`User service running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error("MongoDB connection error:", err);
  });