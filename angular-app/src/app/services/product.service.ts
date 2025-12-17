import { Injectable } from '@angular/core';
import { Product } from '../models/product';

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private products: Product[] = [
    {
      id: 1,
      name: 'ワイヤレスイヤホン',
      description: '高音質Bluetooth対応ワイヤレスイヤホン。ノイズキャンセリング機能付き。',
      price: 12800,
      imageUrl: 'https://picsum.photos/seed/earphone/300/200',
      category: 'オーディオ'
    },
    {
      id: 2,
      name: 'スマートウォッチ',
      description: '健康管理機能搭載のスマートウォッチ。心拍数、睡眠トラッキング対応。',
      price: 24800,
      imageUrl: 'https://picsum.photos/seed/watch/300/200',
      category: 'ウェアラブル'
    },
    {
      id: 3,
      name: 'モバイルバッテリー',
      description: '大容量20000mAhモバイルバッテリー。急速充電対応。',
      price: 3980,
      imageUrl: 'https://picsum.photos/seed/battery/300/200',
      category: 'アクセサリー'
    },
    {
      id: 4,
      name: 'Bluetoothスピーカー',
      description: '防水仕様のポータブルBluetoothスピーカー。アウトドアに最適。',
      price: 8900,
      imageUrl: 'https://picsum.photos/seed/speaker/300/200',
      category: 'オーディオ'
    },
    {
      id: 5,
      name: 'ワイヤレス充電器',
      description: 'Qi対応ワイヤレス充電器。15W急速充電対応。',
      price: 2480,
      imageUrl: 'https://picsum.photos/seed/charger/300/200',
      category: 'アクセサリー'
    },
    {
      id: 6,
      name: 'タブレットスタンド',
      description: '角度調整可能なアルミ製タブレットスタンド。',
      price: 1980,
      imageUrl: 'https://picsum.photos/seed/stand/300/200',
      category: 'アクセサリー'
    }
  ];

  getProducts(): Product[] {
    return this.products;
  }

  getProduct(id: number): Product | undefined {
    return this.products.find(p => p.id === id);
  }
}
