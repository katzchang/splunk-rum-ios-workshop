const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 4200;

// CORS設定（iOSシミュレーターからのアクセスを許可）
app.use(cors());
app.use(express.json());

// 商品データ
const products = [
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

// API エンドポイント

// 商品一覧（200 OK）
app.get('/api/products', (req, res) => {
  res.json(products);
});

// 商品詳細（200 OK）
app.get('/api/products/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const product = products.find(p => p.id === id);
  if (product) {
    res.json(product);
  } else {
    res.status(404).json({ error: '商品が見つかりません' });
  }
});

// テスト用エンドポイント: 200 OK
app.get('/api/test/200', (req, res) => {
  res.json({ status: 'OK', message: '正常なレスポンスです' });
});

// テスト用エンドポイント: 400 Bad Request
app.get('/api/test/400', (req, res) => {
  res.status(400).json({ error: 'Bad Request', message: 'リクエストが不正です' });
});

// テスト用エンドポイント: 500 Internal Server Error
app.get('/api/test/500', (req, res) => {
  res.status(500).json({ error: 'Internal Server Error', message: 'サーバーエラーが発生しました' });
});

// Angular アプリの静的ファイルを配信
app.use(express.static(path.join(__dirname, 'dist/angular-app/browser')));

// SPA用: 全てのルートをindex.htmlにリダイレクト
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist/angular-app/browser/index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
  console.log('API endpoints:');
  console.log('  GET /api/products     - 商品一覧');
  console.log('  GET /api/products/:id - 商品詳細');
  console.log('  GET /api/test/200     - 200 OK');
  console.log('  GET /api/test/400     - 400 Bad Request');
  console.log('  GET /api/test/500     - 500 Internal Server Error');
});
