import React from 'react';

// 1. شارة التوثيق المعتمدة
export const TrustBadge: React.FC<{ label?: string; type?: 'nafath' | 'escrow' | 'inspected' }> = ({
  label = 'موثق عبر نفاذ',
}) => (
  <span
    dir="rtl"
    className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-bold"
  >
    <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
    {label}
  </span>
);

// 2. زر الإجراء التفاعلي الأساسي
export const SouqnaButton: React.FC<{
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'accent' | 'outline';
  icon?: React.ReactNode;
  disabled?: boolean;
}> = ({ title, onPress, variant = 'accent', icon, disabled = false }) => {
  const getStyle = () => {
    switch (variant) {
      case 'primary': return 'bg-[#0f284e] text-white hover:bg-[#08172e]';
      case 'accent': return 'bg-[#ff6f00] text-white hover:bg-[#e66400] shadow-md shadow-orange-500/20';
      case 'outline': return 'bg-white border-2 border-[#0f284e] text-[#0f284e] hover:bg-blue-50';
    }
  };

  return (
    <button
      onClick={onPress}
      disabled={disabled}
      dir="rtl"
      className={`w-full py-3.5 px-6 rounded-2xl font-bold flex items-center justify-center gap-2 transition-all active:scale-[0.98] ${getStyle()} ${
        disabled ? 'opacity-50 cursor-not-allowed' : ''
      }`}
    >
      {icon && <span>{icon}</span>}
      <span>{title}</span>
    </button>
  );
};

// 3. بطاقة السلعة مع الضمان
export const SouqnaProductCard: React.FC<{
  title: string;
  price: number;
  city: string;
  imageUrl: string;
  isInspected?: boolean;
  onPress: () => void;
}> = ({ title, price, city, imageUrl, isInspected = true, onPress }) => (
  <div
    dir="rtl"
    onClick={onPress}
    className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer flex flex-col"
  >
    <div className="relative aspect-video w-full bg-slate-100 overflow-hidden">
      <img src={imageUrl} alt={title} className="w-full h-full object-cover" />
      {isInspected && (
        <div className="absolute top-2.5 right-2.5">
          <TrustBadge label="مفحوص ومضمون" />
        </div>
      )}
    </div>
    <div className="p-3.5 flex flex-col justify-between flex-1">
      <div>
        <h3 className="font-bold text-slate-900 text-sm line-clamp-1">{title}</h3>
        <p className="text-xs text-slate-500 mt-1">📍 {city}</p>
      </div>
      <div className="mt-3 pt-2.5 border-t border-slate-50 flex items-center justify-between">
        <div className="text-[#0f284e] font-black text-base">
          {price.toLocaleString('ar-SA')} <span className="text-xs font-bold text-orange-600">ر.س</span>
        </div>
        <span className="text-[11px] font-bold px-2 py-0.5 bg-blue-50 text-[#0f284e] rounded-md">ضمان بنكي</span>
      </div>
    </div>
  </div>
);
