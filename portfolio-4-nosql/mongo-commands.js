// Portfolio 4: MongoDB (document database), Home of Fantasies
use homeoffantasies

// 1. Products: each product has its own attributes
db.products.insertMany([
  { sku: "LMP-001", name: "Dreamy Cloud Table Lamp", category: "Lighting", price: 34.5, stock: 120,
    supplier: { name: "Supplier 3", city: "Yiwu" },
    attributes: { wattage: 10, bulbType: "LED", colour: "warm white" }, tags: ["lamp", "bedroom"] },
  { sku: "BED-001", name: "Cotton Pillowcase Set", category: "Bedding", price: 18.9, stock: 300,
    supplier: { name: "Supplier 7", city: "Shenzhen" },
    attributes: { size: "Queen", material: "cotton", threadCount: 300, colours: ["ivory", "blush"] }, tags: ["bedding", "soft"] },
  { sku: "RUG-001", name: "Soft Round Rug", category: "Decor", price: 45, stock: 60,
    supplier: { name: "Supplier 12", city: "Guangzhou" },
    attributes: { diameterCm: 120, material: "polyester", washable: true }, tags: ["rug", "living room"] },
  { sku: "CND-001", name: "Vanilla Dream Candle", category: "Fragrance", price: 12.5, stock: 200,
    supplier: { name: "Supplier 3", city: "Yiwu" },
    attributes: { scent: "vanilla", burnHours: 40, weightG: 220 }, tags: ["candle", "gift"] }
])

// 2. Orders: customer, address, items and payment embedded in one document
db.orders.insertMany([
  { orderNo: "HOF-1001", customer: { name: "Ada Obi", email: "ada@example.com", country: "Nigeria" },
    orderDate: new Date("2026-11-01"), status: "paid", shippingAddress: { city: "Lagos", country: "Nigeria" },
    items: [ { sku: "LMP-001", name: "Dreamy Cloud Table Lamp", quantity: 2, unitPrice: 34.5 },
             { sku: "CND-001", name: "Vanilla Dream Candle", quantity: 3, unitPrice: 12.5 } ],
    payment: { method: "card", amount: 106.5 } },
  { orderNo: "HOF-1002", customer: { name: "Kwame Mensah", email: "kwame@example.com", country: "Ghana" },
    orderDate: new Date("2026-11-03"), status: "shipped", shippingAddress: { city: "Accra", country: "Ghana" },
    items: [ { sku: "BED-001", name: "Cotton Pillowcase Set", quantity: 1, unitPrice: 18.9 },
             { sku: "RUG-001", name: "Soft Round Rug", quantity: 1, unitPrice: 45 } ],
    payment: { method: "transfer", amount: 63.9 } },
  { orderNo: "HOF-1003", customer: { name: "Amina Yusuf", email: "amina@example.com", country: "Kenya" },
    orderDate: new Date("2026-11-05"), status: "pending", shippingAddress: { city: "Nairobi", country: "Kenya" },
    items: [ { sku: "CND-001", name: "Vanilla Dream Candle", quantity: 4, unitPrice: 12.5 } ],
    payment: { method: "card", amount: 50 } }
])

// 3. Queries
db.products.find({ "attributes.material": "cotton" })
db.products.find({ price: { $lt: 30 } }, { name: 1, price: 1, _id: 0 })
db.orders.find({ "customer.country": "Nigeria" })

// 4. Update
db.products.updateOne({ sku: "CND-001" }, { $inc: { stock: -3 } })
db.products.find({ sku: "CND-001" }, { name: 1, stock: 1, _id: 0 })

// 5. Aggregation: revenue per product
db.orders.aggregate([
  { $unwind: "$items" },
  { $group: { _id: "$items.sku",
              unitsSold: { $sum: "$items.quantity" },
              revenue: { $sum: { $multiply: ["$items.quantity", "$items.unitPrice"] } } } },
  { $sort: { revenue: -1 } }
])
