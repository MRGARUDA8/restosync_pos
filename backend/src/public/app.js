let token = localStorage.getItem('token') || null;
let socket = null;
let currentProducts = [];
let cart = [];
let selectedTable = 'T1';

document.addEventListener('DOMContentLoaded', () => {
  initApp();
});

function initApp() {
  if (token) {
    showMainLayout();
  } else {
    showLoginScreen();
  }

  // Event Listeners
  document.getElementById('loginForm').addEventListener('submit', handleLogin);
  document.getElementById('logoutBtn').addEventListener('click', handleLogout);

  // Navigation
  document.querySelectorAll('.nav-item').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const tab = e.currentTarget.getAttribute('data-tab');
      switchTab(tab);
    });
  });

  // POS Actions
  document.getElementById('sendKotBtn').addEventListener('click', handleSendKot);
  document.getElementById('payBillBtn').addEventListener('click', handlePayBill);
  document.getElementById('cartDiscountInput').addEventListener('input', updateCartSummary);
  document.getElementById('exportExcelBtn').addEventListener('click', exportExcel);
}

function showLoginScreen() {
  document.getElementById('loginScreen').classList.remove('hidden');
  document.getElementById('mainLayout').classList.add('hidden');
}

function showMainLayout() {
  document.getElementById('loginScreen').classList.add('hidden');
  document.getElementById('mainLayout').classList.remove('hidden');
  initSocket();
  loadDashboard();
}

async function handleLogin(e) {
  e.preventDefault();
  const email = document.getElementById('loginEmail').value;
  const password = document.getElementById('loginPassword').value;

  try {
    const res = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    const data = await res.json();

    if (data.success) {
      token = data.data.accessToken;
      localStorage.setItem('token', token);
      document.getElementById('navUserName').innerText = data.data.user.name;
      document.getElementById('navUserRole').innerText = data.data.user.role;
      showMainLayout();
    } else {
      alert(data.message || 'Login failed.');
    }
  } catch (err) {
    alert('Server connection error.');
  }
}

function handleLogout() {
  token = null;
  localStorage.removeItem('token');
  if (socket) socket.disconnect();
  showLoginScreen();
}

function initSocket() {
  socket = io();
  socket.on('connect', () => {
    console.log('Socket connected');
    socket.emit('join:branch', 'branch-1');
  });

  socket.on('order-created', () => { loadDashboard(); });
  socket.on('kot-created', () => { loadKitchenView(); });
  socket.on('kot-preparing', () => { loadKitchenView(); });
  socket.on('kot-ready', () => { loadKitchenView(); });
  socket.on('bill-generated', () => { loadDashboard(); loadInventory(); });
  socket.on('inventory-updated', (data) => {
    if (data.alert === 'LOW_STOCK') {
      alert(`⚠️ LOW STOCK ALERT: ${data.name} is down to ${data.currentStock} ${data.unit}`);
    }
    loadInventory();
  });
}

function switchTab(tabName) {
  document.querySelectorAll('.nav-item').forEach(b => b.classList.remove('active'));
  document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

  document.querySelectorAll('.tab-view').forEach(v => v.classList.add('hidden'));
  document.getElementById(`${tabName}View`).classList.remove('hidden');

  document.getElementById('currentTabTitle').innerText = tabName.toUpperCase();

  if (tabName === 'dashboard') loadDashboard();
  if (tabName === 'pos') loadPosView();
  if (tabName === 'tables') loadTablesView();
  if (tabName === 'kitchen') loadKitchenView();
  if (tabName === 'inventory') loadInventory();
  if (tabName === 'suppliers') loadSuppliers();
  if (tabName === 'customers') loadCustomers();
  if (tabName === 'reports') loadReports();
}

// API Helper
async function apiFetch(endpoint, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
    ...options.headers
  };
  const res = await fetch(endpoint, { ...options, headers });
  return await res.json();
}

// Load Dashboard Metrics
async function loadDashboard() {
  const res = await apiFetch('/api/reports/dashboard-summary');
  if (res.success) {
    document.getElementById('kpiSales').innerText = `₹${res.data.todaysSales.toFixed(2)}`;
    document.getElementById('kpiOrders').innerText = res.data.todaysOrdersCount;
    document.getElementById('kpiTables').innerText = res.data.activeTables;
    document.getElementById('kpiPendingKots').innerText = res.data.pendingKots;
    renderChart(res.data.topProducts);
  }
}

let chartInstance = null;
function renderChart(products) {
  const ctx = document.getElementById('topProductsChart').getContext('2d');
  if (chartInstance) chartInstance.destroy();

  const labels = products.map(p => p._id);
  const data = products.map(p => p.totalQuantity);

  chartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [{
        label: 'Units Sold',
        data,
        backgroundColor: '#6366f1'
      }]
    },
    options: { responsive: true, plugins: { legend: { display: false } } }
  });
}

// Load POS Products
async function loadPosView() {
  const res = await apiFetch('/api/products');
  if (res.success) {
    currentProducts = res.data;
    renderProducts(currentProducts);
  }
}

function renderProducts(products) {
  const grid = document.getElementById('posProductGrid');
  grid.innerHTML = products.map(p => `
    <div class="product-card" onclick="addToCart('${p._id}')">
      <div class="product-name">${p.name}</div>
      <div class="product-price">₹${p.price.toFixed(2)}</div>
    </div>
  `).join('');
}

function addToCart(productId) {
  const p = currentProducts.find(x => x._id === productId);
  if (!p) return;

  const existing = cart.find(x => x.productId === productId);
  if (existing) {
    existing.quantity += 1;
  } else {
    cart.push({
      productId: p._id,
      name: p.name,
      price: p.price,
      quantity: 1,
      gstRate: p.gstRate || 5
    });
  }
  renderCart();
}

function updateQty(index, delta) {
  cart[index].quantity += delta;
  if (cart[index].quantity <= 0) cart.splice(index, 1);
  renderCart();
}

function renderCart() {
  const container = document.getElementById('cartItemsList');
  if (cart.length === 0) {
    container.innerHTML = '<div class="empty-cart">No items added to order</div>';
  } else {
    container.innerHTML = cart.map((item, idx) => `
      <div class="cart-item">
        <span class="cart-item-name">${item.name}</span>
        <div class="cart-item-qty">
          <button class="qty-btn" onclick="updateQty(${idx}, -1)">-</button>
          <span>${item.quantity}</span>
          <button class="qty-btn" onclick="updateQty(${idx}, 1)">+</button>
        </div>
        <span>₹${(item.price * item.quantity).toFixed(2)}</span>
      </div>
    `).join('');
  }
  updateCartSummary();
}

function updateCartSummary() {
  let subTotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  let gst = subTotal * 0.05;
  let discount = Number(document.getElementById('cartDiscountInput').value) || 0;
  let grandTotal = Math.max(0, Math.round(subTotal + gst - discount));

  document.getElementById('cartSubTotal').innerText = `₹${subTotal.toFixed(2)}`;
  document.getElementById('cartGst').innerText = `₹${gst.toFixed(2)}`;
  document.getElementById('cartGrandTotal').innerText = `₹${grandTotal.toFixed(2)}`;
}

async function handleSendKot() {
  if (cart.length === 0) return alert('Add items to order first.');

  const orderType = document.getElementById('cartOrderType').value;
  const tableNumber = document.getElementById('cartTableSelect').value;

  const res = await apiFetch('/api/orders', {
    method: 'POST',
    body: JSON.stringify({ orderType, tableNumber, items: cart })
  });

  if (res.success) {
    alert(`Order & KOT created successfully! (${res.data.order.orderNumber})`);
    cart = [];
    renderCart();
  }
}

async function handlePayBill() {
  if (cart.length === 0) return alert('Create order first before billing.');

  const orderType = document.getElementById('cartOrderType').value;
  const tableNumber = document.getElementById('cartTableSelect').value;

  // First create order
  const orderRes = await apiFetch('/api/orders', {
    method: 'POST',
    body: JSON.stringify({ orderType, tableNumber, items: cart })
  });

  if (!orderRes.success) return alert('Failed to create order.');

  const discount = Number(document.getElementById('cartDiscountInput').value) || 0;

  // Generate Bill & Trigger Recipe Inventory Engine
  const billRes = await apiFetch('/api/billing/generate', {
    method: 'POST',
    body: JSON.stringify({
      orderId: orderRes.data.order._id,
      discount,
      paymentMethod: 'Cash'
    })
  });

  if (billRes.success) {
    alert(`Bill ${billRes.data.billNumber} Generated & Paid! Ingredients deducted automatically from inventory.`);
    cart = [];
    renderCart();
    // Open Bill PDF download
    window.open(`/api/billing/${billRes.data._id}/pdf`, '_blank');
  }
}

// Load Tables View
async function loadTablesView() {
  const res = await apiFetch('/api/tables');
  if (res.success) {
    const grid = document.getElementById('tablesFloorGrid');
    grid.innerHTML = res.data.map(t => `
      <div class="table-card ${t.status.toLowerCase()}" onclick="toggleTable('${t._id}', '${t.status}')">
        <h4>${t.tableNumber}</h4>
        <p>${t.capacity} Seats</p>
        <span class="badge ${t.status === 'Available' ? 'ok' : 'low'}">${t.status}</span>
      </div>
    `).join('');
  }
}

async function toggleTable(id, status) {
  const newStatus = status === 'Available' ? 'Occupied' : 'Available';
  await apiFetch(`/api/tables/${id}/status`, {
    method: 'PUT',
    body: JSON.stringify({ status: newStatus })
  });
  loadTablesView();
}

// Load Kitchen KDS View
async function loadKitchenView() {
  const res = await apiFetch('/api/kots');
  if (res.success) {
    const grid = document.getElementById('kdsGrid');
    grid.innerHTML = res.data.map(k => `
      <div class="kds-ticket ${k.status.toLowerCase()}">
        <div class="kds-header">
          <span>${k.kotNumber}</span>
          <span>Table: ${k.tableNumber}</span>
        </div>
        <div class="kds-items-list">
          ${k.items.map(i => `<div>${i.quantity}x ${i.name}</div>`).join('')}
        </div>
        <button class="btn btn-primary full-width" onclick="updateKotStatus('${k._id}', '${nextKotStatus(k.status)}')">
          Mark ${nextKotStatus(k.status)}
        </button>
      </div>
    `).join('');
  }
}

function nextKotStatus(status) {
  if (status === 'New') return 'Preparing';
  if (status === 'Preparing') return 'Ready';
  if (status === 'Ready') return 'Served';
  return 'Served';
}

async function updateKotStatus(id, status) {
  await apiFetch(`/api/kots/${id}/status`, {
    method: 'PUT',
    body: JSON.stringify({ status })
  });
  loadKitchenView();
}

// Load Inventory View
async function loadInventory() {
  const res = await apiFetch('/api/inventory/ingredients');
  if (res.success) {
    const body = document.getElementById('inventoryTableBody');
    body.innerHTML = res.data.map(i => `
      <tr>
        <td><b>${i.name}</b></td>
        <td>${i.currentStock}</td>
        <td>${i.unit}</td>
        <td>${i.lowStockThreshold}</td>
        <td>₹${i.costPerUnit}</td>
        <td>
          <span class="badge ${i.currentStock <= i.lowStockThreshold ? 'low' : 'ok'}">
            ${i.currentStock <= i.lowStockThreshold ? 'Low Stock' : 'Sufficient'}
          </span>
        </td>
      </tr>
    `).join('');
  }
}

// Suppliers, Customers, Reports
async function loadSuppliers() {
  const res = await apiFetch('/api/suppliers');
  if (res.success) {
    document.getElementById('suppliersTableBody').innerHTML = res.data.map(s => `
      <tr><td>${s.name}</td><td>${s.contactPerson}</td><td>${s.phone}</td><td>${s.gstin}</td></tr>
    `).join('');
  }
}

async function loadCustomers() {
  const res = await apiFetch('/api/customers');
  if (res.success) {
    document.getElementById('customersTableBody').innerHTML = res.data.map(c => `
      <tr><td>${c.name}</td><td>${c.phone}</td><td>${c.email}</td><td>${c.loyaltyPoints} PTS</td></tr>
    `).join('');
  }
}

async function loadReports() {
  const res = await apiFetch('/api/reports/sales');
  if (res.success) {
    document.getElementById('reportsTableBody').innerHTML = res.data.map(b => `
      <tr>
        <td><b>${b.billNumber}</b></td>
        <td>${b.orderNumber}</td>
        <td>${b.tableNumber || 'Takeaway'}</td>
        <td>${b.paymentMethod}</td>
        <td>₹${b.subTotal.toFixed(2)}</td>
        <td>₹${b.gstTax.toFixed(2)}</td>
        <td><b>₹${b.grandTotal.toFixed(2)}</b></td>
        <td>${new Date(b.createdAt).toLocaleString()}</td>
      </tr>
    `).join('');
  }
}

function exportExcel() {
  window.open('/api/reports/sales?exportType=excel', '_blank');
}
