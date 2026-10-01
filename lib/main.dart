import 'package:flutter/material.dart';

void main() {
  runApp(const ShopbaiApp());
}

// ------------------------------------------------------------------
// GLOBAL STATE DATA
// ------------------------------------------------------------------
class ShopbaiData {
  static ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  static ValueNotifier<String> username = ValueNotifier('Shopbai User');

  static final Map<String, String> registeredUsers = {
    'user': '1234', // Default account
  };

  static ValueNotifier<List<Map<String, String>>> cart = ValueNotifier([]);
  static ValueNotifier<List<Map<String, String>>> purchases = ValueNotifier([]);

  static bool signUp(String user, String pass, BuildContext context) {
    if (user.trim().isEmpty || pass.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mangyaring punan ang lahat ng fields!'), backgroundColor: Colors.red),
      );
      return false;
    }

    if (registeredUsers.containsKey(user.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('May ari na ang username na ito! Pumili ng iba.'), backgroundColor: Colors.red),
      );
      return false;
    }

    if (pass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ang password ay dapat hindi bababa sa 4 characters!'), backgroundColor: Colors.red),
      );
      return false;
    }

    registeredUsers[user.trim()] = pass.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign up successful! Maaari ka nang mag-log in.'), backgroundColor: Colors.green),
    );
    return true;
  }

  static bool login(String user, String pass, BuildContext context) {
    if (user.trim().isEmpty || pass.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mangyaring ilagay ang username at password!'), backgroundColor: Colors.red),
      );
      return false;
    }

    if (!registeredUsers.containsKey(user.trim()) || registeredUsers[user.trim()] != pass.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maling username o password!'), backgroundColor: Colors.red),
      );
      return false;
    }

    username.value = user.trim();
    isLoggedIn.value = true;
    return true;
  }

  static void logout() {
    isLoggedIn.value = false;
    cart.value = [];
  }

  static void addToCart(Map<String, String> item) {
    cart.value = List.from(cart.value)..add(item);
  }

  static void buyNow(Map<String, String> item) {
    purchases.value = List.from(purchases.value)..add(item);
  }

  static void checkoutCart() {
    purchases.value = List.from(purchases.value)..addAll(cart.value);
    cart.value = [];
  }

  static void removeFromCart(Map<String, String> item) {
    final newList = List<Map<String, String>>.from(cart.value);
    newList.remove(item);
    cart.value = newList;
  }
}

class ShopbaiApp extends StatelessWidget {
  const ShopbaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopbai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFEE4D2D),
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEE4D2D),
          elevation: 0,
        ),
      ),
      home: ValueListenableBuilder<bool>(
        valueListenable: ShopbaiData.isLoggedIn,
        builder: (context, loggedIn, child) {
          if (!loggedIn) {
            return const ShopbaiAuthScreen();
          }
          return const ShopbaiMainScreen();
        },
      ),
    );
  }
}

// ------------------------------------------------------------------
// AUTH SCREEN (Stateful para gumana nang maayos ang password input)
// ------------------------------------------------------------------
class ShopbaiAuthScreen extends StatefulWidget {
  const ShopbaiAuthScreen({super.key});

  @override
  State<ShopbaiAuthScreen> createState() => _ShopbaiAuthScreenState();
}

class _ShopbaiAuthScreenState extends State<ShopbaiAuthScreen> {
  bool _isLoginMode = true;
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEE4D2D),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Shopbai', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFEE4D2D))),
                  const SizedBox(height: 8),
                  Text(
                    _isLoginMode ? 'Mag-log in para magsimulang mamili.' : 'Gumawa ng bagong account.',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE4D2D)),
                      onPressed: () {
                        if (_isLoginMode) {
                          ShopbaiData.login(_userController.text, _passController.text, context);
                        } else {
                          bool success = ShopbaiData.signUp(_userController.text, _passController.text, context);
                          if (success) {
                            setState(() {
                              _isLoginMode = true;
                              _passController.clear();
                            });
                          }
                        }
                      },
                      child: Text(_isLoginMode ? 'Login' : 'Sign Up', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                        _userController.clear();
                        _passController.clear();
                      });
                    },
                    child: Text(
                      _isLoginMode ? 'Wala pang account? Mag-sign up' : 'May account na? Mag-login',
                      style: const TextStyle(color: Color(0xFFEE4D2D)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// MAIN NAVIGATION SCREEN
// ------------------------------------------------------------------
class ShopbaiMainScreen extends StatefulWidget {
  const ShopbaiMainScreen({super.key});

  @override
  State<ShopbaiMainScreen> createState() => _ShopbaiMainScreenState();
}

class _ShopbaiMainScreenState extends State<ShopbaiMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ShopbaiHomeBody(),
    const ShopbaiFeedBody(),
    const ShopbaiLiveBody(),
    const ShopbaiCartBody(),
    const ShopbaiMeBody(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 1200 ? 1200.0 : screenWidth;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFEE4D2D),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
          const BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), label: 'Live'),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<List<Map<String, String>>>(
              valueListenable: ShopbaiData.cart,
              builder: (context, cartItems, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (cartItems.isNotEmpty)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('${cartItems.length}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      )
                  ],
                );
              },
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// PAHINA 1: HOME
// ------------------------------------------------------------------
class ShopbaiHomeBody extends StatefulWidget {
  const ShopbaiHomeBody({super.key});

  @override
  State<ShopbaiHomeBody> createState() => _ShopbaiHomeBodyState();
}

class _ShopbaiHomeBodyState extends State<ShopbaiHomeBody> {
  String _searchQuery = '';

  final List<Map<String, String>> _allProducts = [
    {'name': 'Wireless Earbuds with Noise Cancellation', 'price': '₱299.00', 'icon': '🎧'},
    {'name': 'Trendy Sneakers For Men and Women', 'price': '₱499.00', 'icon': '👟'},
    {'name': 'Complete Makeup Set 24pcs', 'price': '₱199.50', 'icon': '💄'},
    {'name': 'Smart Watch Fitness Tracker', 'price': '₱899.00', 'icon': '⌚'},
    {'name': 'Portable Juicer Blender USB', 'price': '₱350.00', 'icon': '🥤'},
    {'name': 'Powerbank 20000mAh Fast Charging', 'price': '₱599.00', 'icon': '🔋'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _allProducts.where((product) {
      return product['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFEE4D2D), floating: true, pinned: true, titleSpacing: 10,
            title: Container(
              height: 38, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.chat_outlined, color: Colors.white), onPressed: () {}),
            ],
          ),
          if (_searchQuery.isEmpty) ...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    height: 140, color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView(
                      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10),
                      children: [
                        _buildBanner(context, 'Flash Sale!\nUp to 80% Off', Colors.redAccent, 'Shop Now >'),
                        const SizedBox(width: 10),
                        _buildBanner(context, 'New Deals\nEvery Day', Colors.blueAccent, 'See Deals >'),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white, padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: const [Icon(Icons.bolt, color: Colors.orange, size: 24), SizedBox(width: 4), Text('Flash Deals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange))]),
                            Row(children: [const Text('Ends in: ', style: TextStyle(fontSize: 12, color: Colors.grey)), _buildTimerBox('01'), const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)), _buildTimerBox('35'), const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)), _buildTimerBox('45')]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _allProducts.map((item) => _buildProductCard(context, item['name']!, item['price']!, item['icon']!, width: 140)).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, childAspectRatio: 0.72, mainAxisSpacing: 8, crossAxisSpacing: 8),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (filteredProducts.isEmpty) return const SizedBox.shrink();
                  final item = filteredProducts[index % filteredProducts.length];
                  return _buildProductCard(context, item['name']!, item['price']!, item['icon']!);
                },
                childCount: filteredProducts.isEmpty ? 0 : filteredProducts.length * 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, String title, Color color, String btnText) {
    return Container(
      width: 280, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(btnText, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  Widget _buildTimerBox(String time) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)), child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)));
  }

  Widget _buildProductCard(BuildContext context, String name, String price, String icon, {double? width}) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ShopbaiProductDetailsScreen(name: name, price: price, icon: icon)));
      },
      child: Container(
        width: width, margin: width != null ? const EdgeInsets.only(right: 10) : null, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container(width: double.infinity, color: Colors.grey.shade100, child: Center(child: Text(icon, style: const TextStyle(fontSize: 60))))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(color: Color(0xFFEE4D2D), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// PRODUCT DETAILS SCREEN
// ------------------------------------------------------------------
class ShopbaiProductDetailsScreen extends StatelessWidget {
  final String name;
  final String price;
  final String icon;

  const ShopbaiProductDetailsScreen({super.key, required this.name, required this.price, required this.icon});

  void _showQuantitySheet(BuildContext context, bool isBuyNow) {
    int quantity = 1;
    String cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    double basePrice = double.tryParse(cleanPrice) ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double totalPrice = basePrice * quantity;

            return Container(
              height: 260,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80, height: 80,
                        color: Colors.grey.shade100,
                        child: Center(child: Text(icon, style: const TextStyle(fontSize: 40))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('₱${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFEE4D2D), fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Stock: 99+', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: quantity > 1 ? const Color(0xFFEE4D2D) : Colors.grey,
                            onPressed: () {
                              if (quantity > 1) {
                                setModalState(() { quantity--; });
                              }
                            },
                          ),
                          Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFEE4D2D)),
                            onPressed: () {
                              setModalState(() { quantity++; });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE4D2D)),
                      onPressed: () {
                        final Map<String, String> productData = {
                          'name': name,
                          'price': '₱${totalPrice.toStringAsFixed(2)}',
                          'icon': icon,
                          'quantity': quantity.toString(),
                        };

                        Navigator.pop(context);

                        if (isBuyNow) {
                          ShopbaiData.buyNow(productData);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Successful!'), backgroundColor: Colors.green));
                          Navigator.pop(context);
                        } else {
                          ShopbaiData.addToCart(productData);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!'), backgroundColor: Colors.teal));
                        }
                      },
                      child: Text('Confirm ${isBuyNow ? "Purchase" : "Cart"}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('Product Details', style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: double.infinity, height: 350, color: Colors.white, child: Center(child: Text(icon, style: const TextStyle(fontSize: 150)))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, color: Colors.white, padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(price, style: const TextStyle(color: Color(0xFFEE4D2D), fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () => _showQuantitySheet(context, false),
                child: Container(height: 60, color: Colors.teal.shade50, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.add_shopping_cart, color: Colors.teal), Text('Add to Cart', style: TextStyle(color: Colors.teal, fontSize: 12))])),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () => _showQuantitySheet(context, true),
                child: Container(height: 60, color: const Color(0xFFEE4D2D), child: const Center(child: Text('Buy Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// PAHINA 4: CART
// ------------------------------------------------------------------
class ShopbaiCartBody extends StatelessWidget {
  const ShopbaiCartBody({super.key});

  double _calculateTotal(List<Map<String, String>> items) {
    double total = 0;
    for (var item in items) {
      String cleanPrice = item['price']!.replaceAll(RegExp(r'[^0-9.]'), '');
      total += double.tryParse(cleanPrice) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart', style: TextStyle(color: Colors.white))),
      body: ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: ShopbaiData.cart,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Walang laman ang iyong cart.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final qty = item['quantity'] ?? '1';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Text(item['icon']!, style: const TextStyle(fontSize: 40)),
                        title: Text(item['name']!, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Row(
                          children: [
                            Text(item['price']!, style: const TextStyle(color: Color(0xFFEE4D2D), fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Text('x$qty', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => ShopbaiData.removeFromCart(item),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('₱${_calculateTotal(cartItems).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEE4D2D))),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE4D2D), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                      onPressed: () {
                        ShopbaiData.checkoutCart();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout Successful!'), backgroundColor: Colors.green));
                      },
                      child: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------
// PAHINA 5: ME
// ------------------------------------------------------------------
class ShopbaiMeBody extends StatelessWidget {
  const ShopbaiMeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile', style: TextStyle(color: Colors.white))),
      body: ListView(
        children: [
          Container(
            color: const Color(0xFFEE4D2D), padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.grey)),
                const SizedBox(width: 16),
                ValueListenableBuilder<String>(
                  valueListenable: ShopbaiData.username,
                  builder: (context, user, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Followers: 0 | Following: 0', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blue),
            title: const Text('My Purchases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopbaiPurchasesScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              ShopbaiData.logout();
            },
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// MY PURCHASES SCREEN
// ------------------------------------------------------------------
class ShopbaiPurchasesScreen extends StatelessWidget {
  const ShopbaiPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Purchases', style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: ShopbaiData.purchases,
        builder: (context, purchasedItems, child) {
          if (purchasedItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Wala ka pang nabibili.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: purchasedItems.length,
            itemBuilder: (context, index) {
              final item = purchasedItems[index];
              final qty = item['quantity'] ?? '1';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Text(item['icon']!, style: const TextStyle(fontSize: 40)),
                  title: Text(item['name']!, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Row(
                    children: [
                      Text(item['price']!, style: const TextStyle(color: Color(0xFFEE4D2D))),
                      const SizedBox(width: 10),
                      Text('Qty: $qty', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  trailing: const Text('To Receive', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// PAHINA 2 & 3
class ShopbaiFeedBody extends StatelessWidget {
  const ShopbaiFeedBody({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Feed', style: TextStyle(color: Colors.white))), body: const Center(child: Text('No Posts Yet', style: TextStyle(color: Colors.grey))));
}
class ShopbaiLiveBody extends StatelessWidget {
  const ShopbaiLiveBody({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Live', style: TextStyle(color: Colors.white))), body: const Center(child: Text('No Live Streams', style: TextStyle(color: Colors.grey))));
}