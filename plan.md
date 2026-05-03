Phân tích app tham khảo (Text Editor by TapUniverse) 
  Kiến trúc đã decompile được:                                                                                                                             
  - View Controllers: DocumentBrowserViewController, DocumentViewController, CreateViewController, OnboardingViewController + Onboarding2ViewController,
  SubscriptionViewController + PreSubViewController, FontSizeViewController, ReplaceTextViewController, RatingViewController, LoadingViewController        
  - Custom UI: RichTextTools, SearchTools, ColorKeyboard, FontKeyboard, ParagraphKeyboard, RulerView, TextViewInputView, MenuDropdown              
  - Models: Document (UIDocument), Settings, RTColor                                                                                                       
  - Frameworks: Alamofire, SwiftyStoreKit, TPInAppReceipt, KeychainAccess, JWT, ASN1Swift                                                                  
  - File types: .txt, .rtf (export); import được .ovpn, .srt, .conf                                                                                        
  - IAP: Weekly / Yearly / Lifetime (com.tapuniverse.texteditor.w, .y)                                                                                     
  - Min iOS: 15.0 — sử dụng UIKit + Storyboard + UIDocumentBrowserViewController                                                                           
                                                                                                                                                           
  ---                                                                                                                                                      
  Plan dự án JustEdit                                                                                                                                      
                                                                                                                                                           
  1. Mục tiêu sản phẩm
                                                                                                                                                           
  App soạn thảo văn bản đa dụng cho iPhone/iPad: tạo/mở/chỉnh sửa file .txt & .rtf, kèm rich text formatting toolbar, custom keyboards                     
  (color/font/paragraph), find & replace, paywall subscription.
                                                                                                                                                           
  2. Tech stack đề xuất                                                                                                                                    
   
  ┌───────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐   
  │   Hạng mục    │                                                              Lựa chọn                                                              │
  ├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ UI            │ SwiftUI cho file browser/onboarding/paywall + UIViewRepresentable bọc UITextView cho editor (RTF cần NSAttributedString → UIKit là │
  │               │  phù hợp nhất)                                                                                                                     │
  ├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤   
  │ Document      │ UIDocument subclass + DocumentBrowserViewController (giữ giống bản gốc)                                                            │
  │ model         │                                                                                                                                    │   
  ├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤   
  │ State         │ @Observable (iOS 17+) hoặc ObservableObject                                                                                        │
  ├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤   
  │ IAP           │ StoreKit 2 (thay thế SwiftyStoreKit đã deprecated)                                                                                 │
  ├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤   
  │ Networking    │ URLSession (Alamofire không cần thiết)                                                                                             │
  ├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤   
  │ Keychain      │ KeychainAccess hoặc tự wrap                                                                                                        │
  ├───────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤   
  │ Min iOS       │ 16.0 (cân bằng marketshare & API mới)                                                                                              │
  └───────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘   
                  
  3. Danh sách chức năng (theo độ ưu tiên)                                                                                                                 
                  
  Phase 1 — Core Editor (MVP)                                                                                                                              
                  
  1. Document Browser — iCloud Drive + On My iPhone, tạo/đổi tên/xoá/copy file                                                                             
  2. Create file flow — chọn .txt hoặc .rtf, đặt tên
  3. Editor cơ bản — UITextView với auto-save (UIDocument), undo/redo                                                                                      
  4. Open in Place — mở file từ Files app, share extension                                                                                                 
  5. Rich Text Toolbar (RichTextTools):                                                                                                                    
    - Bold / Italic / Underline / Strikethrough                                                                                                            
    - Heading levels, list (bullet/number), alignment, indent                                                                                              
  6. Font picker (FontKeyboard) — bundle sẵn fonts như app gốc: Cairo, Montserrat, OpenSans, RobotoCondensed, Pacifico, DancingScript, NewYork, SF         
  Pro/Mono/Rounded                                                                                                                                         
  7. Font size keyboard (FontSizeViewController)                                                                                                           
  8. Color keyboard (ColorKeyboard) — text color + highlight                                                                                               
  9. Paragraph keyboard (ParagraphKeyboard) — line spacing, paragraph spacing, indent                                                                      
  10. Ruler view (RulerView) — tab stops, indent                                                                                                           
                                                                                                                                                           
  Phase 2 — Search & Productivity                                                                                                                          
                                                                                                                                                           
  11. Find & Replace (SearchTools + ReplaceTextViewController)
  12. Word/character count
  13. Export — .txt, .rtf, .pdf, share sheet                                                                                                               
  14. Print (UIPrintInteractionController)                                                                                                                 
  15. Dark mode + theme settings                                                                                                                           
  16. Page setup (margin, paper size cho print/PDF)                                                                                                        
                                                                                                                                                           
  Phase 3 — Onboarding & Monetization
                                                                                                                                                           
  17. Onboarding 2 màn (giống bản gốc)                                                                                                                     
  18. Paywall — Weekly / Yearly / Lifetime, free trial, restore purchases
  19. Pre-subscription teaser sau onboarding                                                                                                               
  20. Rating prompt sau N lần mở file thành công                                                                                                           
                                                                                                                                                           
  Phase 4 — Polish                                                                                                                                         
                                                                                                                                                           
  21. iPad layout — sidebar + editor (NavigationSplitView)                                                                                                 
  22. Keyboard shortcuts (⌘B, ⌘I, ⌘F, ⌘S…)
  23. External keyboard support                                                                                                                            
  24. Drag & drop ảnh/text
  25. Insert image vào RTF                                                                                                                                 
  26. Templates (letter, note, list)
  27. Localization (EN, VI tối thiểu)                                                                                                                      
                                                                                                                                                           
  4. Cấu trúc thư mục đề xuất                                                                                                                              
                                                                                                                                                           
  JustEdit/       
  ├── App/                    JustEditApp.swift, AppDelegate.swift
  ├── DocumentBrowser/        DocumentBrowserVC, CreateDocument flow                                                                                       
  ├── Editor/                                                                                                                                              
  │   ├── Document.swift      (UIDocument)                                                                                                                 
  │   ├── DocumentVC.swift                                                                                                                                 
  │   ├── TextView/           UITextView wrapper, InputAccessory                                                                                           
  │   └── Toolbars/           RichTextTools, SearchTools, RulerView                                                                                        
  ├── Keyboards/              FontKeyboard, ColorKeyboard, ParagraphKeyboard                                                                               
  ├── Onboarding/             Onboarding1VC, Onboarding2VC, PreSubVC                                                                                       
  ├── Subscription/           SubscriptionVC, StoreKitCenter (StoreKit 2)                                                                                  
  ├── Settings/               Settings model, SettingsView                                                                                                 
  ├── Common/                 Extensions, Theme, RTColor                                                                                                   
  ├── Resources/                                                                                                                                           
  │   ├── Fonts/              (.ttf/.otf giống bản gốc)                                                                                                    
  │   └── Assets.xcassets                                                                                                                                  
  └── Tests/
                                                                                                                                                           
  5. Roadmap (gợi ý timeline)                                                                                                                              
   
  - Tuần 1–2: Phase 1 (core editor + document browser + rich text toolbar)                                                                                 
  - Tuần 3: Phase 1 các custom keyboards + ruler
  - Tuần 4: Phase 2 (find/replace, export, PDF)                                                                                                            
  - Tuần 5: Phase 3 (onboarding + paywall StoreKit 2)                                                                                                      
  - Tuần 6: Phase 4 (iPad, shortcuts, polish, localization)                                                                                                
  - Tuần 7: QA, Test Flight, submit App Store                                                                                                              
                                                                                                                                                           
  6. Rủi ro & lưu ý                                                                                                                                        
                  
  - RTF rendering: một số attribute (paragraph style, list) cần custom serialize để khớp giữa platforms — test kỹ với file tạo từ Pages/Word               
  - Font licensing: các font Cairo/Montserrat/Roboto/OpenSans/Pacifico là OFL/Apache, OK; SF Pro/Mono chỉ dùng được qua API hệ thống (không bundle file
  .otf trong app store khi submit, dùng UIFont.systemFont/.monospacedSystemFont)                                                                           
  - StoreKit 2: rẻ và bảo trì tốt hơn SwiftyStoreKit — không nên copy nguyên approach cũ
  - iCloud: cần entitlement com.apple.developer.icloud-container-identifiers + iCloud Documents  