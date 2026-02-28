-- ========================================
-- 자연도감 (Nature Collection App)
-- Initial Database Schema
-- ========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- 1. 사용자 프로필 (Supabase auth.users 확장)
-- ========================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname VARCHAR(50) NOT NULL,
    avatar_url TEXT,
    birth_year INTEGER,
    is_parent BOOLEAN DEFAULT FALSE,
    total_collections INTEGER DEFAULT 0,
    eco_points INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 새 사용자 가입 시 프로필 자동 생성 트리거
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, nickname)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'nickname', '탐험가'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ========================================
-- 2. 생물 종 마스터 데이터
-- ========================================
CREATE TABLE species (
    id SERIAL PRIMARY KEY,
    korean_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(200),
    category VARCHAR(20) NOT NULL CHECK (category IN (
        'insect', 'plant', 'fish', 'bird', 'mammal',
        'reptile', 'amphibian', 'mushroom', 'marine'
    )),
    subcategory VARCHAR(50),
    description TEXT,
    habitat VARCHAR(50) CHECK (habitat IN (
        'land', 'freshwater', 'sea', 'mountain', 'forest', 'urban', 'wetland'
    )),
    rarity_tier INTEGER DEFAULT 1 CHECK (rarity_tier BETWEEN 1 AND 5),
    color_code VARCHAR(7),
    fun_fact TEXT,
    eco_message TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 3. 사용자 컬렉션 (채집한 카드)
-- ========================================
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    card_number VARCHAR(20) UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    species_id INTEGER NOT NULL REFERENCES species(id),
    photo_url TEXT NOT NULL,
    thumbnail_url TEXT,
    gps_latitude DOUBLE PRECISION,
    gps_longitude DOUBLE PRECISION,
    location_name VARCHAR(200),
    stats JSONB NOT NULL DEFAULT '{}'::jsonb,
    original_owner_id UUID NOT NULL REFERENCES profiles(id),
    co_discoverers TEXT[],
    discovered_at TIMESTAMPTZ DEFAULT NOW(),
    is_public BOOLEAN DEFAULT FALSE,
    is_synced BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 카드 번호 시퀀스
CREATE SEQUENCE card_number_seq START 1;

-- 카드 번호 자동 생성 함수
CREATE OR REPLACE FUNCTION generate_card_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.card_number IS NULL OR NEW.card_number = '' THEN
        NEW.card_number := 'NC-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(nextval('card_number_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_card_number
    BEFORE INSERT ON collections
    FOR EACH ROW EXECUTE FUNCTION generate_card_number();

-- 컬렉션 수 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_collection_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE profiles SET total_collections = total_collections + 1 WHERE id = NEW.user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE profiles SET total_collections = total_collections - 1 WHERE id = OLD.user_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_collection_change
    AFTER INSERT OR DELETE ON collections
    FOR EACH ROW EXECUTE FUNCTION update_collection_count();

-- ========================================
-- 4. 소유권 변경 이력
-- ========================================
CREATE TABLE ownership_history (
    id SERIAL PRIMARY KEY,
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    from_user_id UUID REFERENCES profiles(id),
    to_user_id UUID NOT NULL REFERENCES profiles(id),
    transfer_type VARCHAR(20) NOT NULL CHECK (transfer_type IN ('discovery', 'trade', 'gift')),
    transferred_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 5. 그림일기
-- ========================================
CREATE TABLE diary_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    collection_id UUID REFERENCES collections(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    text_content TEXT,
    drawing_url TEXT,
    voice_url TEXT,
    mood VARCHAR(20) CHECK (mood IN ('happy', 'excited', 'curious', 'calm', 'surprised')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 6. 교환 요청 (Phase 3)
-- ========================================
CREATE TABLE trades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES profiles(id),
    receiver_id UUID NOT NULL REFERENCES profiles(id),
    sender_card_id UUID NOT NULL REFERENCES collections(id),
    receiver_card_id UUID REFERENCES collections(id),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')),
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- ========================================
-- 7. 환경 미션 (Phase 4)
-- ========================================
CREATE TABLE eco_missions (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    reward_points INTEGER DEFAULT 10,
    category VARCHAR(20),
    difficulty INTEGER DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 3),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_missions (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES profiles(id),
    mission_id INTEGER NOT NULL REFERENCES eco_missions(id),
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    photo_proof_url TEXT,
    UNIQUE(user_id, mission_id)
);

-- ========================================
-- 인덱스
-- ========================================
CREATE INDEX idx_collections_user ON collections(user_id);
CREATE INDEX idx_collections_species ON collections(species_id);
CREATE INDEX idx_collections_category ON collections USING GIN ((stats));
CREATE INDEX idx_collections_discovered ON collections(discovered_at DESC);
CREATE INDEX idx_diary_user ON diary_entries(user_id);
CREATE INDEX idx_diary_created ON diary_entries(created_at DESC);
CREATE INDEX idx_ownership_collection ON ownership_history(collection_id);
CREATE INDEX idx_species_category ON species(category);
CREATE INDEX idx_species_korean_name ON species(korean_name);
CREATE INDEX idx_trades_sender ON trades(sender_id);
CREATE INDEX idx_trades_receiver ON trades(receiver_id);

-- ========================================
-- Row Level Security (RLS)
-- ========================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE diary_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE ownership_history ENABLE ROW LEVEL SECURITY;

-- 프로필: 누구나 조회, 본인만 수정
CREATE POLICY profiles_select ON profiles FOR SELECT USING (true);
CREATE POLICY profiles_insert ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY profiles_update ON profiles FOR UPDATE USING (auth.uid() = id);

-- 컬렉션: 본인 전체 접근, 공개 카드 조회 가능
CREATE POLICY collections_owner ON collections FOR ALL USING (auth.uid() = user_id);
CREATE POLICY collections_public_read ON collections FOR SELECT USING (is_public = TRUE);

-- 일기: 본인만 접근
CREATE POLICY diary_owner ON diary_entries FOR ALL USING (auth.uid() = user_id);

-- 교환: 본인 관련 교환만 조회, 본인이 보낸 것만 생성/수정
CREATE POLICY trades_participant ON trades FOR SELECT
    USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY trades_sender ON trades FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY trades_update ON trades FOR UPDATE
    USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

-- 소유권 이력: 관련자만 조회
CREATE POLICY ownership_read ON ownership_history FOR SELECT
    USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

-- ========================================
-- 초기 시드 데이터: 한국 대표 생물종
-- ========================================
INSERT INTO species (korean_name, scientific_name, category, subcategory, habitat, rarity_tier, color_code, description, fun_fact, eco_message) VALUES
-- 곤충
('호랑나비', 'Papilio xuthus', 'insect', '나비목', 'land', 2, '#2E7D32', '날개에 호랑이 무늬가 있는 큰 나비입니다.', '호랑나비의 애벌레는 귤나무 잎을 좋아해요!', '나비 친구를 관찰한 후 자유롭게 날아가게 해줘요!'),
('무당벌레', 'Coccinella septempunctata', 'insect', '딱정벌레목', 'land', 1, '#2E7D32', '빨간 등에 검은 점이 있는 귀여운 벌레입니다.', '무당벌레는 진딧물을 잡아먹어 식물을 지켜줘요!', '무당벌레를 살짝 관찰하고 나뭇잎 위에 올려놓아줘요!'),
('장수풍뎅이', 'Allomyrina dichotoma', 'insect', '딱정벌레목', 'forest', 3, '#2E7D32', '크고 멋진 뿔이 있는 풍뎅이입니다.', '장수풍뎅이의 뿔은 수컷만 가지고 있어요!', '장수풍뎅이를 관찰한 후 숲 속으로 보내줘요!'),
('꿀벌', 'Apis mellifera', 'insect', '벌목', 'land', 1, '#2E7D32', '꽃의 꿀을 모으는 부지런한 벌입니다.', '꿀벌 한 마리가 평생 만드는 꿀은 찻숟가락 하나 정도예요!', '꿀벌은 멀리서 관찰해요! 건드리면 아프답니다!'),
('사슴벌레', 'Lucanus maculifemoratus', 'insect', '딱정벌레목', 'forest', 3, '#2E7D32', '사슴뿔처럼 큰 턱을 가진 벌레입니다.', '사슴벌레의 큰 턱은 싸울 때 상대를 집어던지는 데 사용해요!', '사슴벌레를 사진으로 기록하고 숲으로 돌려보내줘요!'),
-- 식물
('개나리', 'Forsythia koreana', 'plant', '꽃', 'urban', 1, '#66BB6A', '봄에 노란 꽃이 피는 한국의 대표적인 관목입니다.', '개나리는 한국에서만 자라는 특별한 꽃이에요!', '꽃은 꺾지 말고 눈으로 관찰해요!'),
('무궁화', 'Hibiscus syriacus', 'plant', '꽃', 'urban', 2, '#66BB6A', '대한민국의 국화입니다.', '무궁화는 아침에 피고 저녁에 지지만 매일 새로운 꽃이 펴요!', '우리나라의 국화를 소중히 관찰해봐요!'),
('소나무', 'Pinus densiflora', 'plant', '나무', 'mountain', 2, '#66BB6A', '한국의 산에서 가장 흔히 볼 수 있는 나무입니다.', '소나무는 겨울에도 푸른 잎을 유지하는 상록수예요!', '나무껍질을 벗기지 말고 관찰만 해요!'),
('은행나무', 'Ginkgo biloba', 'plant', '나무', 'urban', 2, '#66BB6A', '가을에 노란 잎이 아름다운 나무입니다.', '은행나무는 공룡시대부터 살아온 살아있는 화석이에요!', '은행잎은 주워서 책갈피로 만들어봐요!'),
-- 조류
('참새', 'Passer montanus', 'bird', '참새목', 'urban', 1, '#FF8F00', '우리 주변에서 가장 흔히 볼 수 있는 새입니다.', '참새는 한 발로 서서 자는 경우도 있어요!', '새들은 멀리서 조용히 관찰해요!'),
('까치', 'Pica sericea', 'bird', '참새목', 'urban', 1, '#FF8F00', '검은색과 흰색이 섞인 한국의 텃새입니다.', '까치는 도구를 사용할 줄 아는 매우 똑똑한 새예요!', '까치 둥지를 건드리지 말고 관찰만 해요!'),
('왜가리', 'Ardea cinerea', 'bird', '황새목', 'wetland', 2, '#FF8F00', '긴 다리와 목을 가진 큰 물새입니다.', '왜가리는 물고기를 잡을 때 돌처럼 가만히 서서 기다려요!', '물새는 멀리서 관찰하면 더 자연스러운 모습을 볼 수 있어요!'),
-- 포유류
('다람쥐', 'Sciurus vulgaris', 'mammal', '설치목', 'forest', 2, '#8D6E63', '작고 귀여운 숲 속 동물입니다.', '다람쥐는 먹이를 숨겨두고 잊어버려서 나무가 자라요!', '다람쥐에게 먹이를 주지 않아도 돼요. 스스로 잘 찾아먹어요!'),
('고라니', 'Hydropotes inermis', 'mammal', '우제목', 'forest', 3, '#8D6E63', '한국의 산과 들에 사는 작은 사슴입니다.', '고라니는 뿔이 없는 대신 긴 송곳니를 가지고 있어요!', '야생동물을 만나면 조용히 물러나요!'),
-- 어류
('붕어', 'Carassius auratus', 'fish', '잉어목', 'freshwater', 1, '#1565C0', '민물에 사는 대표적인 물고기입니다.', '붕어는 기억력이 3초라고 하지만 사실 몇 달까지 기억해요!', '물고기는 물 밖으로 꺼내지 말고 물속에서 관찰해요!'),
-- 파충류
('줄장지뱀', 'Takydromus wolteri', 'reptile', '뱀목', 'land', 2, '#7B1FA2', '들판에서 볼 수 있는 작은 도마뱀입니다.', '줄장지뱀은 위험하면 꼬리를 스스로 끊고 도망가요! 꼬리는 다시 자라요!', '도마뱀을 잡으면 안 돼요! 사진으로만 기록해요!'),
-- 양서류
('청개구리', 'Hyla japonica', 'amphibian', '개구리목', 'wetland', 2, '#00897B', '비 오기 전에 많이 우는 작은 개구리입니다.', '청개구리는 발에 있는 빨판으로 유리창도 올라갈 수 있어요!', '개구리를 만졌다면 손을 꼭 씻어야 해요!'),
-- 버섯
('느타리버섯', 'Pleurotus ostreatus', 'mushroom', '느타리목', 'forest', 1, '#D84315', '나무에서 자라는 식용 버섯입니다.', '느타리버섯은 죽은 나무를 분해해서 숲을 깨끗하게 해줘요!', '야생 버섯은 절대 먹으면 안 돼요! 사진으로만 관찰해요!'),
-- 해양생물
('꽃게', 'Portunus trituberculatus', 'marine', '십각목', 'sea', 2, '#0277BD', '바다에 사는 맛있는 게입니다.', '꽃게는 옆으로 걸어요! 그래야 더 빨리 움직일 수 있거든요!', '갯벌 생물을 관찰한 후 바다로 돌려보내줘요!');
