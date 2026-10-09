class FactoryProfile {
  final String factoryName;
  final String companyName;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String gstNumber;
  final String fssaiLicense; // Essential for food/juice manufacturing in India
  final String invoicePrefix;
  final String? logoUrl;

  FactoryProfile({
    this.factoryName = 'JuiceFlow Manufacturing Plant #1',
    this.companyName = 'FreshVibe Agro & Beverages Pvt Ltd',
    this.address = 'Plot 42, Food Processing Industrial Park, Theni - 625531, Tamil Nadu',
    this.phone = '+91 98421 55678',
    this.email = 'operations@freshvibejuice.com',
    this.website = 'www.freshvibejuice.com',
    this.gstNumber = '33AABCF9876Q1Z3',
    this.fssaiLicense = '12423999000145',
    this.invoicePrefix = 'JF-INV-',
    this.logoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'factory_name': factoryName,
      'company_name': companyName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'gst_number': gstNumber,
      'fssai_license': fssaiLicense,
      'invoice_prefix': invoicePrefix,
      'logo_url': logoUrl,
    };
  }

  factory FactoryProfile.fromMap(Map<String, dynamic> map) {
    return FactoryProfile(
      factoryName: map['factory_name']?.toString() ?? 'JuiceFlow Manufacturing Plant #1',
      companyName: map['company_name']?.toString() ?? 'FreshVibe Agro & Beverages Pvt Ltd',
      address: map['address']?.toString() ?? 'Plot 42, Food Processing Industrial Park, Theni - 625531, Tamil Nadu',
      phone: map['phone']?.toString() ?? '+91 98421 55678',
      email: map['email']?.toString() ?? 'operations@freshvibejuice.com',
      website: map['website']?.toString() ?? 'www.freshvibejuice.com',
      gstNumber: map['gst_number']?.toString() ?? '33AABCF9876Q1Z3',
      fssaiLicense: map['fssai_license']?.toString() ?? '12423999000145',
      invoicePrefix: map['invoice_prefix']?.toString() ?? 'JF-INV-',
      logoUrl: map['logo_url']?.toString(),
    );
  }

  FactoryProfile copyWith({
    String? factoryName,
    String? companyName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? gstNumber,
    String? fssaiLicense,
    String? invoicePrefix,
    String? logoUrl,
  }) {
    return FactoryProfile(
      factoryName: factoryName ?? this.factoryName,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      gstNumber: gstNumber ?? this.gstNumber,
      fssaiLicense: fssaiLicense ?? this.fssaiLicense,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
