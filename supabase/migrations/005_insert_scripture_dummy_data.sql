-- Migration: Insert Scripture Dummy Data
-- Description: Inserts sample scripture data for testing (20+ items, including premium)
-- Date: 2026-01-16
-- Phase: 2-1 (Scripture Delivery System)

-- ============================================
-- Insert Non-Premium Scriptures (15 items)
-- ============================================
INSERT INTO public.scriptures (book, chapter, verse, content, reference, is_premium, category) VALUES

-- Hope Category
('John', 3, 16,
 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
 'John 3:16', FALSE, 'hope'),

('Jeremiah', 29, 11,
 'For I know the plans I have for you, declares the LORD, plans to prosper you and not to harm you, plans to give you hope and a future.',
 'Jeremiah 29:11', FALSE, 'hope'),

('Romans', 15, 13,
 'May the God of hope fill you with all joy and peace as you trust in him, so that you may overflow with hope by the power of the Holy Spirit.',
 'Romans 15:13', FALSE, 'hope'),

-- Wisdom Category
('Proverbs', 3, 5,
 'Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
 'Proverbs 3:5-6', FALSE, 'wisdom'),

('James', 1, 5,
 'If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault, and it will be given to you.',
 'James 1:5', FALSE, 'wisdom'),

('Proverbs', 9, 10,
 'The fear of the LORD is the beginning of wisdom, and knowledge of the Holy One is understanding.',
 'Proverbs 9:10', FALSE, 'wisdom'),

-- Faith Category
('Philippians', 4, 13,
 'I can do all this through him who gives me strength.',
 'Philippians 4:13', FALSE, 'faith'),

('Hebrews', 11, 1,
 'Now faith is confidence in what we hope for and assurance about what we do not see.',
 'Hebrews 11:1', FALSE, 'faith'),

('Mark', 11, 24,
 'Therefore I tell you, whatever you ask for in prayer, believe that you have received it, and it will be yours.',
 'Mark 11:24', FALSE, 'faith'),

-- Comfort Category
('Psalms', 23, 4,
 'Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me.',
 'Psalms 23:4', FALSE, 'comfort'),

('Matthew', 11, 28,
 'Come to me, all you who are weary and burdened, and I will give you rest.',
 'Matthew 11:28', FALSE, 'comfort'),

('Isaiah', 41, 10,
 'So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you; I will uphold you with my righteous right hand.',
 'Isaiah 41:10', FALSE, 'comfort'),

-- Strength Category
('Joshua', 1, 9,
 'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the LORD your God will be with you wherever you go.',
 'Joshua 1:9', FALSE, 'strength'),

('Isaiah', 40, 31,
 'But those who hope in the LORD will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
 'Isaiah 40:31', FALSE, 'strength'),

('2 Timothy', 1, 7,
 'For the Spirit God gave us does not make us timid, but gives us power, love and self-discipline.',
 '2 Timothy 1:7', FALSE, 'strength');

-- ============================================
-- Insert Premium Scriptures (8 items)
-- ============================================
INSERT INTO public.scriptures (book, chapter, verse, content, reference, is_premium, category) VALUES

-- Premium Hope
('Psalms', 42, 11,
 'Why, my soul, are you downcast? Why so disturbed within me? Put your hope in God, for I will yet praise him, my Savior and my God.',
 'Psalms 42:11', TRUE, 'hope'),

('Lamentations', 3, 22,
 'Because of the LORD''s great love we are not consumed, for his compassions never fail. They are new every morning; great is your faithfulness.',
 'Lamentations 3:22-23', TRUE, 'hope'),

-- Premium Wisdom
('Colossians', 3, 16,
 'Let the message of Christ dwell among you richly as you teach and admonish one another with all wisdom through psalms, hymns, and songs from the Spirit, singing to God with gratitude in your hearts.',
 'Colossians 3:16', TRUE, 'wisdom'),

('Proverbs', 2, 6,
 'For the LORD gives wisdom; from his mouth come knowledge and understanding.',
 'Proverbs 2:6', TRUE, 'wisdom'),

-- Premium Faith
('Romans', 10, 17,
 'Consequently, faith comes from hearing the message, and the message is heard through the word about Christ.',
 'Romans 10:17', TRUE, 'faith'),

('Galatians', 2, 20,
 'I have been crucified with Christ and I no longer live, but Christ lives in me. The life I now live in the body, I live by faith in the Son of God, who loved me and gave himself for me.',
 'Galatians 2:20', TRUE, 'faith'),

-- Premium Comfort
('2 Corinthians', 1, 3,
 'Praise be to the God and Father of our Lord Jesus Christ, the Father of compassion and the God of all comfort, who comforts us in all our troubles.',
 '2 Corinthians 1:3-4', TRUE, 'comfort'),

-- Premium Strength
('Ephesians', 6, 10,
 'Finally, be strong in the Lord and in his mighty power. Put on the full armor of God, so that you can take your stand against the devil''s schemes.',
 'Ephesians 6:10-11', TRUE, 'strength');

-- ============================================
-- Verify data insertion
-- ============================================
-- Expected: 15 non-premium + 8 premium = 23 total scriptures
