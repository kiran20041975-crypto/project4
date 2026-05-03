const express = require("express");

const app = express();
app.use(express.json());

// Payment API
app.post("/pay", (req, res) => {
  const { orderId } = req.body;

  console.log("Payment processed for order:", orderId);

  res.send({
    status: "SUCCESS",
    orderId
  });
});

// Health check
app.get("/", (req, res) => {
  res.send("Payment Service is running");
});

app.listen(3004, () => {
  console.log("Payment service running on port 3004");
});