import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate, Outlet, Navigate } from 'react-router-dom';
import { LayoutDashboard, ShoppingBag, LogOut, Users, Menu, X } from 'lucide-react';
import toast from 'react-hot-toast';

export default function Dashboard() {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  if (!currentUser) {
    return <Navigate to="/login" replace />;
  }

  async function handleLogout() {
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      toast.error('Failed to log out');
    }
  }

  const SidebarContent = () => (
    <>
      <div className="p-6 flex items-center gap-3">
        <img src="/assets/the_urban_bite_logo.png" alt="Logo" className="w-10 h-10 object-cover rounded-full border border-gray-200" />
        <div>
          <h1 className="text-lg font-bold text-gray-900">Admin Panel</h1>
          <p className="text-xs text-gray-500">The urban bite</p>
        </div>
      </div>

      <nav className="flex-1 px-4 space-y-1 mt-4">
        <a href="#" onClick={() => setIsSidebarOpen(false)} className="flex items-center gap-3 px-4 py-3 bg-[#0C831F] text-white rounded-lg font-medium shadow-sm">
          <ShoppingBag size={20} />
          Orders
        </a>
        <a href="#" className="flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 rounded-lg font-medium transition-colors">
          <LayoutDashboard size={20} />
          Products (Coming soon)
        </a>
        <a href="#" className="flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 rounded-lg font-medium transition-colors">
          <Users size={20} />
          Delivery Boys (Coming soon)
        </a>
      </nav>

      <div className="p-4 border-t border-gray-200">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 w-full text-red-600 hover:bg-red-50 rounded-lg font-medium transition-colors"
        >
          <LogOut size={20} />
          Logout
        </button>
      </div>
    </>
  );

  return (
    <div className="flex h-screen bg-gray-50 font-sans overflow-hidden">
      {/* Sidebar for Desktop */}
      <div className="hidden md:flex w-64 bg-white border-r border-gray-200 shadow-sm flex-col shrink-0">
        <SidebarContent />
      </div>

      {/* Sidebar Overlay and Drawer for Mobile */}
      {isSidebarOpen && (
        <div className="fixed inset-0 z-40 flex md:hidden">
          {/* Backdrop */}
          <div
            className="fixed inset-0 bg-gray-600 bg-opacity-75 transition-opacity"
            onClick={() => setIsSidebarOpen(false)}
          ></div>

          {/* Drawer Panel */}
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white shadow-xl transition transform ease-in-out duration-300">
            <div className="absolute top-0 right-0 -mr-12 pt-2">
              <button
                className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white bg-gray-800 bg-opacity-50"
                onClick={() => setIsSidebarOpen(false)}
              >
                <X className="text-white" size={24} />
              </button>
            </div>
            <SidebarContent />
          </div>
        </div>
      )}

      {/* Main Content Pane */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Mobile Header */}
        <header className="md:hidden bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between shadow-sm shrink-0">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setIsSidebarOpen(true)}
              className="p-2 -ml-2 text-gray-500 hover:text-gray-700 focus:outline-none"
            >
              <Menu size={24} />
            </button>
            <img src="/assets/the_urban_bite_logo.png" alt="Logo" className="w-8 h-8 object-cover rounded-full" />
            <span className="font-bold text-gray-900 text-sm">The Urban Bite</span>
          </div>
        </header>

        {/* Content Body */}
        <div className="flex-1 overflow-auto focus:outline-none">
          <Outlet />
        </div>
      </div>
    </div>
  );
}
