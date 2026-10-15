import React, { useState, useEffect, useRef } from 'react';
import { db } from '../firebaseConfig';
import { collection, onSnapshot, query, orderBy, doc, updateDoc, getDocs } from 'firebase/firestore';
import { Search, Eye, Filter, Truck, User, Bell } from 'lucide-react';
import toast from 'react-hot-toast';

const playNotificationSound = () => {
  try {
    const context = new (window.AudioContext || window.webkitAudioContext)();
    const playNote = (frequency, startTime, duration) => {
      const osc = context.createOscillator();
      const gain = context.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(frequency, startTime);
      gain.gain.setValueAtTime(0.4, startTime);
      gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
      osc.connect(gain);
      gain.connect(context.destination);
      osc.start(startTime);
      osc.stop(startTime + duration);
    };
    // Play two notes (C5 then E5) to make a clean digital bell sound
    playNote(523.25, context.currentTime, 0.35); // C5
    playNote(659.25, context.currentTime + 0.12, 0.5); // E5
  } catch (e) {
    console.error("Audio Context failed to play chime", e);
  }
};

export default function OrdersList() {
  const [orders, setOrders] = useState([]);
  const [deliveryBoys, setDeliveryBoys] = useState([]);
  const [users, setUsers] = useState({});
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [dateFilter, setDateFilter] = useState('all');
  
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const isInitialLoadRef = useRef(true);
  
  const [notifications, setNotifications] = useState([]);
  const [isNotificationOpen, setIsNotificationOpen] = useState(false);
  const [highlightedOrderId, setHighlightedOrderId] = useState(null);
  const notificationRef = useRef(null);

  const clearAllNotifications = () => {
    setNotifications([]);
    setIsNotificationOpen(false);
    toast.success('All notifications cleared');
  };

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (notificationRef.current && !notificationRef.current.contains(event.target)) {
        setIsNotificationOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const handleNotificationClick = (notif) => {
    // Reset filters to guarantee it is visible in the list
    setSearchTerm('');
    setStatusFilter('all');
    setDateFilter('all');
    
    setTimeout(() => {
      const rowElement = document.getElementById(`order-row-${notif.id}`);
      if (rowElement) {
        rowElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
        setHighlightedOrderId(notif.id);
        
        // Remove highlight after 2.5 seconds
        setTimeout(() => {
          setHighlightedOrderId(null);
        }, 2500);
      } else {
        toast.error('Order row not found in list');
      }
    }, 150);

    setIsNotificationOpen(false);
  };

  useEffect(() => {
    // Fetch delivery boys once
    const fetchDeliveryBoys = async () => {
      try {
        const q = query(collection(db, 'delivery_boys'));
        const querySnapshot = await getDocs(q);
        const boys = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        setDeliveryBoys(boys);
      } catch (err) {
        console.error("Error fetching delivery boys", err);
      }
    };
    fetchDeliveryBoys();

    // Listen to users
    const unsubscribeUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      const usersMap = {};
      snapshot.forEach((doc) => {
        usersMap[doc.id] = doc.data();
      });
      setUsers(usersMap);
    }, (error) => {
      console.error("Failed to fetch users", error);
    });

    // Listen to orders
    const q = query(collection(db, 'orders'), orderBy('createdAt', 'desc'));
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const ordersData = [];
      const isInitial = isInitialLoadRef.current;
      
      snapshot.docChanges().forEach((change) => {
        if (change.type === 'added' && !isInitial) {
          // If a new order is added after the initial load, show a notification & play chime
          const totalAmount = change.doc.data().totalAmount || 0;
          toast.success(`New Order Received! ID: ${change.doc.id.substring(0, 6)}`, {
            duration: 5000,
            icon: '🔔',
          });
          playNotificationSound();
          
          const newNotif = {
            id: change.doc.id,
            message: `New Order #${change.doc.id.substring(0, 8)}... placed for ₹${totalAmount}`,
            timestamp: new Date(),
          };
          setNotifications(prev => [newNotif, ...prev]);
        }
      });

      snapshot.forEach((doc) => {
        ordersData.push({ id: doc.id, ...doc.data() });
      });
      
      setOrders(ordersData);
      setLoading(false);
      isInitialLoadRef.current = false;
    }, (error) => {
      toast.error('Failed to fetch orders');
      console.error(error);
      setLoading(false);
    });

    return () => {
      unsubscribe();
      unsubscribeUsers();
    };
  }, []);

  const handleStatusChange = async (orderId, newStatus) => {
    try {
      const orderRef = doc(db, 'orders', orderId);
      await updateDoc(orderRef, { status: newStatus });
      toast.success('Order status updated');
      if (selectedOrder && selectedOrder.id === orderId) {
        setSelectedOrder({ ...selectedOrder, status: newStatus });
      }
    } catch (error) {
      toast.error('Failed to update status');
    }
  };

  const handleAssignDelivery = async (orderId, boyId) => {
    try {
      const boy = deliveryBoys.find(b => b.id === boyId);
      if (!boy) return;
      
      const orderRef = doc(db, 'orders', orderId);
      await updateDoc(orderRef, { 
        deliveryBoy: {
          id: boy.id,
          name: boy.name,
          phone: boy.phone
        } 
      });
      toast.success('Delivery assigned');
      if (selectedOrder && selectedOrder.id === orderId) {
        setSelectedOrder({ 
          ...selectedOrder, 
          deliveryBoy: { id: boy.id, name: boy.name, phone: boy.phone } 
        });
      }
    } catch (error) {
      toast.error('Failed to assign delivery');
    }
  };

  const openOrderDetails = (order) => {
    setSelectedOrder(order);
    setIsModalOpen(true);
  };

  const filteredOrders = orders.filter(order => {
    const user = users[order.userId] || {};
    const userName = (user.name || '').toLowerCase();
    const userPhone = (user.phoneNumber || user.phone || '').toLowerCase();
    const userEmail = (user.email || '').toLowerCase();
    const addressStr = order.deliveryAddress 
      ? `${order.deliveryAddress.house || order.deliveryAddress.houseNo || ''} ${order.deliveryAddress.area || ''} ${order.deliveryAddress.city || ''} ${order.deliveryAddress.pincode || ''}`.toLowerCase()
      : '';
    
    // Check if search matches order ID, customer name/phone/email, address, or any item names
    const matchesSearch = 
      order.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      userName.includes(searchTerm.toLowerCase()) ||
      userPhone.includes(searchTerm.toLowerCase()) ||
      userEmail.includes(searchTerm.toLowerCase()) ||
      addressStr.includes(searchTerm.toLowerCase()) ||
      (order.items && order.items.some(item => item.name.toLowerCase().includes(searchTerm.toLowerCase())));
      
    const matchesStatus = statusFilter === 'all' || order.status === statusFilter;
    
    // Date range matches
    let matchesDate = true;
    if (dateFilter !== 'all' && order.createdAt) {
      const orderDate = new Date(order.createdAt?.seconds * 1000);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      yesterday.setHours(0, 0, 0, 0);
      
      const last7Days = new Date();
      last7Days.setDate(last7Days.getDate() - 7);
      last7Days.setHours(0, 0, 0, 0);

      const thisMonth = new Date(today.getFullYear(), today.getMonth(), 1);

      const orderZeroTime = new Date(orderDate);
      orderZeroTime.setHours(0, 0, 0, 0);
      
      if (dateFilter === 'today') {
        matchesDate = orderZeroTime.getTime() === today.getTime();
      } else if (dateFilter === 'yesterday') {
        matchesDate = orderZeroTime.getTime() === yesterday.getTime();
      } else if (dateFilter === 'week') {
        matchesDate = orderDate >= last7Days;
      } else if (dateFilter === 'month') {
        matchesDate = orderDate >= thisMonth;
      }
    } else if (dateFilter !== 'all' && !order.createdAt) {
      matchesDate = false;
    }
    
    return matchesSearch && matchesStatus && matchesDate;
  });

  const getStatusColor = (status) => {
    switch (status) {
      case 'placed': return 'bg-yellow-100 text-yellow-800';
      case 'out_for_delivery': return 'bg-orange-100 text-orange-800';
      case 'delivered': return 'bg-green-100 text-green-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
    return <div className="p-8 flex justify-center"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#0C831F]"></div></div>;
  }

  return (
    <div className="p-4 sm:p-8">
      <div className="flex justify-between items-center mb-8 relative">
        <h2 className="text-xl sm:text-2xl font-bold text-gray-900">Orders Management</h2>
        
        {/* Notification Bell Dropdown */}
        <div className="relative" ref={notificationRef}>
          <button 
            onClick={() => setIsNotificationOpen(!isNotificationOpen)}
            className="relative p-2 text-gray-500 hover:text-gray-700 bg-white rounded-full border border-gray-200 shadow-sm focus:outline-none transition-all hover:scale-105"
            title="Notifications"
          >
            <Bell size={22} className="text-[#0C831F]" />
            {notifications.length > 0 && (
              <span className="absolute top-0 right-0 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white leading-none transform translate-x-1 -translate-y-1">
                {notifications.length}
              </span>
            )}
          </button>
          
          {isNotificationOpen && (
            <div className="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg border border-gray-200 py-2 z-50 animate-fade-in">
              <div className="flex justify-between items-center px-4 py-2 border-b border-gray-100">
                <span className="font-bold text-gray-800 text-sm">Notifications ({notifications.length})</span>
                {notifications.length > 0 && (
                  <button 
                    onClick={clearAllNotifications}
                    className="text-xs text-[#0C831F] hover:underline font-semibold"
                  >
                    Clear All
                  </button>
                )}
              </div>
              <div className="max-h-64 overflow-y-auto divide-y divide-gray-100">
                {notifications.length === 0 ? (
                  <div className="p-4 text-center text-sm text-gray-500">
                    No new notifications.
                  </div>
                ) : (
                  notifications.map(notif => (
                    <div 
                      key={notif.id} 
                      onClick={() => handleNotificationClick(notif)}
                      className="p-3 hover:bg-gray-50 cursor-pointer transition-colors"
                      title="Click to view order details"
                    >
                      <p className="text-xs text-gray-700 font-medium">{notif.message}</p>
                      <span className="text-[10px] text-gray-400 font-mono mt-1 block">
                        {notif.timestamp.toLocaleTimeString()}
                      </span>
                    </div>
                  ))
                )}
              </div>
            </div>
          )}
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        {/* Filters and Search */}
        <div className="p-4 border-b border-gray-200 flex flex-col sm:flex-row gap-4 justify-between items-center bg-gray-50">
          <div className="relative w-full sm:w-96">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input 
              type="text" 
              placeholder="Search by ID, Customer details, or Dish name..." 
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#0C831F]"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
            <Filter size={20} className="text-gray-400" />
            
            {/* Date Filter */}
            <select 
              className="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#0C831F] bg-white text-sm"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
            >
              <option value="all">All Dates</option>
              <option value="today">Today</option>
              <option value="yesterday">Yesterday</option>
              <option value="week">Last 7 Days</option>
              <option value="month">This Month</option>
            </select>

            {/* Status Filter */}
            <select 
              className="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#0C831F] bg-white text-sm"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="all">All Status</option>
              <option value="placed">Placed</option>
              <option value="out_for_delivery">Out for Delivery</option>
              <option value="delivered">Delivered</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-white border-b border-gray-200">
                <th className="p-4 text-sm font-semibold text-gray-600">Order & Items</th>
                <th className="p-4 text-sm font-semibold text-gray-600">Date</th>
                <th className="p-4 text-sm font-semibold text-gray-600">Customer Details</th>
                <th className="p-4 text-sm font-semibold text-gray-600">Delivery Address</th>
                <th className="p-4 text-sm font-semibold text-gray-600">Amount</th>
                <th className="p-4 text-sm font-semibold text-gray-600">Status</th>
                <th className="p-4 text-sm font-semibold text-gray-600">Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredOrders.length === 0 ? (
                <tr>
                  <td colSpan="7" className="p-8 text-center text-gray-500">No orders found.</td>
                </tr>
              ) : (
                filteredOrders.map(order => {
                  const customer = users[order.userId] || {};
                  const addr = order.deliveryAddress || {};
                  const addressStr = order.deliveryAddress
                    ? `${addr.house || addr.houseNo || ''}, ${addr.area || ''}, ${addr.city || ''} - ${addr.pincode || ''}`
                    : 'N/A';
                    
                  return (
                    <tr 
                      key={order.id} 
                      id={`order-row-${order.id}`}
                      className={`border-b border-gray-100 transition-all duration-500 ${
                        highlightedOrderId === order.id 
                          ? 'bg-green-50 border-green-200 scale-[1.005] shadow-sm' 
                          : 'hover:bg-gray-50'
                      }`}
                    >
                      <td className="p-4 text-sm font-medium text-gray-900">
                        <div className="flex flex-col gap-2 max-w-xs">
                          <span className="text-xs text-gray-500 font-mono font-semibold">#{order.id.substring(0, 8)}...</span>
                          <div className="flex flex-col gap-1">
                            {order.items && order.items.map((item, idx) => (
                              <div key={idx} className="flex items-center gap-2">
                                <img src={item.image && item.image.startsWith('assets/') ? `/${item.image}` : item.image} alt={item.name} className="w-8 h-8 object-cover rounded border border-gray-100" />
                                <div className="text-xs leading-tight">
                                  <p className="font-semibold text-gray-800">{item.name}</p>
                                  <p className="text-gray-500">Qty: {item.quantity} x {item.count}</p>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      </td>
                      <td className="p-4 text-sm text-gray-500">
                        {order.createdAt ? new Date(order.createdAt?.seconds * 1000).toLocaleString() : 'N/A'}
                      </td>
                      <td className="p-4 text-sm text-gray-700">
                        <div className="flex flex-col gap-0.5">
                          <span className="font-bold text-gray-900 flex items-center gap-1">
                            <User size={14} className="text-gray-400" />
                            {customer.name || 'Anonymous User'}
                          </span>
                          <span className="text-xs text-gray-500">{customer.phoneNumber || customer.phone || 'No phone'}</span>
                          <span className="text-xs text-gray-500">{customer.email || 'No email'}</span>
                        </div>
                      </td>
                      <td className="p-4 text-sm text-gray-600 max-w-[220px] whitespace-normal break-words" title={addressStr}>
                        {addressStr}
                      </td>
                      <td className="p-4 text-sm font-bold text-gray-900">
                        ₹{order.totalAmount}
                      </td>
                      <td className="p-4">
                        <span className={`px-3 py-1 rounded-full text-xs font-medium capitalize ${getStatusColor(order.status)}`}>
                          {order.status?.replace('_', ' ')}
                        </span>
                      </td>
                      <td className="p-4">
                        <button 
                          onClick={() => openOrderDetails(order)}
                          className="p-2 text-[#0C831F] hover:bg-green-50 rounded-lg transition-colors"
                          title="View Details"
                        >
                          <Eye size={20} />
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Order Details Modal */}
      {isModalOpen && selectedOrder && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-2xl max-h-[90vh] flex flex-col">
            <div className="p-6 border-b border-gray-200 flex justify-between items-center">
              <h3 className="text-xl font-bold text-gray-900">Order Details</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">✕</button>
            </div>
            
            <div className="p-6 overflow-y-auto flex-1">
              <div className="grid grid-cols-2 gap-6 mb-6">
                <div>
                  <p className="text-sm text-gray-500 mb-1">Order ID</p>
                  <p className="font-medium text-gray-900">{selectedOrder.id}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500 mb-1">Date</p>
                  <p className="font-medium text-gray-900">
                     {selectedOrder.createdAt ? new Date(selectedOrder.createdAt?.seconds * 1000).toLocaleString() : 'N/A'}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500 mb-1">Customer Details</p>
                  <div className="text-sm text-gray-900">
                    <p className="font-bold">{users[selectedOrder.userId]?.name || 'Anonymous User'}</p>
                    <p className="text-xs text-gray-500">Phone: {users[selectedOrder.userId]?.phoneNumber || users[selectedOrder.userId]?.phone || 'N/A'}</p>
                    <p className="text-xs text-gray-500">Email: {users[selectedOrder.userId]?.email || 'N/A'}</p>
                    <p className="text-[10px] text-gray-400 font-mono mt-0.5">UID: {selectedOrder.userId}</p>
                  </div>
                </div>
                <div>
                  <p className="text-sm text-gray-500 mb-1">Total Amount</p>
                  <p className="font-bold text-[#0C831F] text-lg">₹{selectedOrder.totalAmount}</p>
                </div>
              </div>

              <div className="mb-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
                <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                  <Truck size={18} /> Delivery Information
                </h4>
                {selectedOrder.deliveryAddress ? (
                  <p className="text-sm text-gray-700">
                    {selectedOrder.deliveryAddress.house || selectedOrder.deliveryAddress.houseNo || ''}, {selectedOrder.deliveryAddress.area || ''}, {selectedOrder.deliveryAddress.city || ''} - {selectedOrder.deliveryAddress.pincode || ''}
                  </p>
                ) : (
                  <p className="text-sm text-gray-500 italic">No delivery address provided.</p>
                )}
              </div>

              <div className="mb-8">
                <h4 className="font-semibold text-gray-900 mb-3">Order Items</h4>
                <div className="border border-gray-200 rounded-lg divide-y divide-gray-200">
                  {selectedOrder.items && selectedOrder.items.map((item, idx) => (
                    <div key={idx} className="p-3 flex justify-between items-center">
                      <div className="flex items-center gap-3">
                        <img src={item.image && item.image.startsWith('assets/') ? `/${item.image}` : item.image} alt={item.name} className="w-12 h-12 object-cover rounded" />
                        <div>
                          <p className="text-sm font-medium text-gray-900">{item.name}</p>
                          <p className="text-xs text-gray-500">Qty: {item.quantity} x {item.count || 1}</p>
                        </div>
                      </div>
                      <p className="text-sm font-medium text-gray-900">₹{item.price * (item.count || 1)}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Actions */}
              <div className="border-t border-gray-200 pt-6">
                <h4 className="font-semibold text-gray-900 mb-4">Manage Order</h4>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Update Status</label>
                    <select 
                      className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#0C831F]"
                      value={selectedOrder.status}
                      onChange={(e) => handleStatusChange(selectedOrder.id, e.target.value)}
                    >
                      <option value="placed">Placed</option>
                      <option value="out_for_delivery">Out for Delivery</option>
                      <option value="delivered">Delivered</option>
                      <option value="cancelled">Cancelled</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Assign Delivery Boy</label>
                    <select 
                      className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#0C831F]"
                      value={selectedOrder.deliveryBoy?.id || ''}
                      onChange={(e) => handleAssignDelivery(selectedOrder.id, e.target.value)}
                    >
                      <option value="" disabled>Select Delivery Boy</option>
                      {deliveryBoys.map(boy => (
                        <option key={boy.id} value={boy.id}>{boy.name}</option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
