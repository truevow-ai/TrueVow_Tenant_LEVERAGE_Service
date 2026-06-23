-- Seed data for leverage.leverage_valuation_multipliers
-- One row per state with jurisdiction-aware PI valuation multiplier ranges.
-- Multipliers derived from comparative fault rules:
--   Contributory (bar at any fault):       1.5x - 2.0x medical specials
--   Modified comparative 50% (bar at 50%): 2.0x - 2.5x
--   Modified comparative 51% (bar at 51%): 2.5x - 3.0x
--   Pure comparative (no bar):             3.0x - 4.0x
-- Source: Industry settlement data + state comparative fault statutes

INSERT INTO leverage.leverage_valuation_multipliers (state, medical_multiplier_low, medical_multiplier_high, comparative_fault_rule, typical_contingency_pct, notes, source) VALUES
-- Contributory negligence states (bar at ANY plaintiff fault)
('AL', 1.5, 2.0, 'contributory', 33.33, 'Alabama: Pure contributory negligence — plaintiff barred from recovery at any fault %', 'Ala. Code § 6-11-1 (common law)'),
('MD', 1.5, 2.0, 'contributory', 33.33, 'Maryland: Pure contributory negligence — one of only 4 remaining states', 'Maryland common law; contributory since 1847'),
('NC', 1.5, 2.0, 'contributory', 33.33, 'North Carolina: Pure contributory negligence — one of only 4 remaining states', 'N.C. Gen. Stat. § 99B-4 (common law)'),

('VA', 1.5, 2.0, 'contributory', 33.33, 'Virginia: Pure contributory negligence — one of only 4 remaining states', 'Va. Code § 8.01-17 (common law)'),

-- Modified comparative 50% bar (plaintiff must be LESS than 50% at fault)
('AR', 2.0, 2.5, 'modified_50', 33.33, 'Arkansas: Modified comparative — plaintiff barred at 50% fault', 'Ark. Code Ann. § 16-64-101'),
('DE', 2.0, 2.5, 'modified_50', 33.33, 'Delaware: Modified comparative 50% bar', '10 Del. C. § 8132'),
('GA', 2.0, 2.5, 'modified_50', 33.33, 'Georgia: Modified comparative — strict 50% bar (must be less than 50%)', 'O.C.G.A. § 51-12-33'),
('ID', 2.0, 2.5, 'modified_50', 33.33, 'Idaho: Strict 50% bar — plaintiff must be less than 50% at fault', 'Idaho Code § 6-801'),
('KS', 2.0, 2.5, 'modified_50', 33.33, 'Kansas: Modified comparative 50% bar', 'Kan. Stat. Ann. § 60-258a'),
('ME', 2.0, 2.5, 'modified_50', 33.33, 'Maine: Modified comparative 50% bar; longest PI SOL at 6 years', '14 M.R.S. § 156'),
('MN', 2.0, 2.5, 'modified_50', 33.33, 'Minnesota: Modified comparative 50% bar', 'Minn. Stat. § 604.01'),
('ND', 2.0, 2.5, 'modified_50', 33.33, 'North Dakota: Modified comparative 50% bar', 'N.D. Cent. Code § 32-03.2-02'),
('OK', 2.0, 2.5, 'modified_50', 33.33, 'Oklahoma: Modified comparative 50% bar', '23 Okla. Stat. § 13'),
('TN', 2.0, 2.5, 'modified_50', 33.33, 'Tennessee: Modified comparative 50% bar; 1-year SOL (shortest in U.S.)', 'Tenn. Code Ann. § 29-11-103'),
('UT', 2.0, 2.5, 'modified_50', 33.33, 'Utah: Modified comparative 50% bar', 'Utah Code § 78B-5-818'),
('WY', 2.0, 2.5, 'modified_50', 33.33, 'Wyoming: Modified comparative 50% bar', 'Wyo. Stat. Ann. § 1-1-109'),

-- Modified comparative 51% bar (plaintiff barred at 51% or more)
('AZ', 2.5, 3.0, 'modified_51', 33.33, 'Arizona: Modified comparative 51% bar', 'Ariz. Rev. Stat. § 12-2505'),
('CT', 2.5, 3.0, 'modified_51', 33.33, 'Connecticut: Modified comparative 51% bar', 'C.G.S. § 52-572h'),
('CO', 2.5, 3.0, 'modified_51', 33.33, 'Colorado: Modified comparative — several liability (not joint and several)', 'C.R.S. § 13-21-111'),
('FL', 2.5, 3.0, 'modified_51', 33.33, 'Florida: Modified comparative 51% bar; 2023 HB 837 reduced SOL from 4 to 2 years', 'F.S. § 768.81 (2023 reform)'),
('HI', 2.5, 3.0, 'modified_51', 33.33, 'Hawaii: Modified comparative 51% bar', 'HRS § 663-11'),
('IL', 2.5, 3.0, 'modified_51', 33.33, 'Illinois: Modified comparative 51% bar; abolished joint and several liability', '735 ILCS 5/2-1116'),
('IN', 2.5, 3.0, 'modified_51', 33.33, 'Indiana: Modified comparative 51% bar; several liability only', 'Ind. Code § 34-51-2-6'),
('IA', 2.5, 3.0, 'modified_51', 33.33, 'Iowa: Modified comparative — plaintiff cannot recover if fault >= 51%', 'Iowa Code § 668.3'),
('KY', 2.5, 3.0, 'modified_51', 33.33, 'Kentucky: Pure comparative adopted via common law; 1-year SOL', 'Kentucky common law; comparative since 1985'),
('MA', 2.5, 3.0, 'modified_51', 33.33, 'Massachusetts: Modified comparative — plaintiff barred at 51%+', 'Mass. Gen. Laws ch. 231 § 85'),
('MI', 2.5, 3.0, 'modified_51', 33.33, 'Michigan: Modified comparative — plaintiff barred at 51%+; threshold damage requirement for auto', 'MCL 600.2919a'),
('MS', 2.5, 3.0, 'modified_51', 33.33, 'Mississippi: Modified comparative — plaintiff barred if more at fault than defendant', 'Miss. Code Ann. § 11-7-15'),
('MO', 2.5, 3.0, 'modified_51', 33.33, 'Missouri: Pure comparative via common law until 2021; now modified comparative', 'Mo. Rev. Stat. § 537.765 (2021)'),
('MT', 2.5, 3.0, 'modified_51', 33.33, 'Montana: Modified comparative 51% bar', 'Mont. Code Ann. § 27-1-302'),
('NE', 2.5, 3.0, 'modified_51', 33.33, 'Nebraska: Modified comparative — plaintiff barred at 51%+; 4-year SOL', 'Neb. Rev. Stat. § 25-21,185.09'),
('NV', 2.5, 3.0, 'modified_51', 33.33, 'Nevada: Modified comparative 51% bar', 'NRS § 41.141'),
('NH', 2.5, 3.0, 'modified_51', 33.33, 'New Hampshire: Modified comparative 51% bar', 'N.H. Rev. Stat. § 507:7-d'),
('NJ', 2.5, 3.0, 'modified_51', 33.33, 'New Jersey: Modified comparative — plaintiff barred at 51%+', 'N.J.S.A. § 2A:15-5.1'),
('NM', 2.5, 3.0, 'modified_51', 33.33, 'New Mexico: Pure comparative via common law; mixed signals in statute', 'N.M. Stat. § 41-3A-1 (mixed)'),
('NY', 2.5, 3.0, 'modified_51', 33.33, 'New York: Modified comparative 51% bar; joint and several liability preserved', 'N.Y. C.P.L.R. § 1411'),
('OH', 2.5, 3.0, 'modified_51', 33.33, 'Ohio: Modified comparative — open and obvious eliminates duty in premises', 'Ohio Rev. Code § 2315.33'),
('OR', 2.5, 3.0, 'modified_51', 33.33, 'Oregon: Modified comparative 51% bar', 'ORS § 31.610'),
('PA', 2.5, 3.0, 'modified_51', 33.33, 'Pennsylvania: Modified comparative 51% bar; Hills and Ridges doctrine for slip-fall', '42 Pa.C.S. § 7102'),
('SC', 2.5, 3.0, 'modified_51', 33.33, 'South Carolina: Modified comparative — plaintiff barred at 51%+ (statutory override of contributory)', 'S.C. Code § 15-1-300 (2022 reform)'),
('TX', 2.5, 3.0, 'modified_51', 33.33, 'Texas: Modified comparative 51% bar; strict notice requirements for premises', 'Tex. Civ. Prac. & Rem. Code § 33.001'),
('WA', 2.5, 3.0, 'modified_51', 33.33, 'Washington: Pure comparative via common law; several liability', 'Wash. common law; RCW 4.22.070'),
('WV', 2.5, 3.0, 'modified_51', 33.33, 'West Virginia: Modified comparative 51% bar', 'W. Va. Code § 55-7-13a'),
('WI', 2.5, 3.0, 'modified_51', 33.33, 'Wisconsin: Modified comparative 51% bar; Safe Place Statute for premises', 'Wis. Stat. § 895.045'),

-- Pure comparative fault (plaintiff can recover even at 99% fault)
('AK', 3.0, 4.0, 'pure', 33.33, 'Alaska: Pure comparative negligence', 'Alaska Stat. § 09.17.060'),
('CA', 3.0, 4.0, 'pure', 33.33, 'California: Pure comparative via Li v. Yellow Cab; Civil Code 1714 general duty', 'Cal. Civ. Code § 1714; Li v. Yellow Cab (1975)'),
('DC', 3.0, 4.0, 'pure', 33.33, 'District of Columbia: Pure comparative (overturned contributory in 2021 for some claims)', 'D.C. Code § 2-1203.03'),
('LA', 3.0, 4.0, 'pure', 40.00, 'Louisiana: Pure comparative; civil law system; Merchant Liability Act; higher contingency typical', 'La. R.S. 9:2800.6; La. Civ. Code Art. 2323'),
('RI', 3.0, 4.0, 'pure', 33.33, 'Rhode Island: Pure comparative negligence', 'R.I. Gen. Laws § 9-20-4'),
('VT', 3.0, 4.0, 'pure', 33.33, 'Vermont: Pure comparative negligence', '12 V.S.A. § 1036')
ON CONFLICT (state) DO UPDATE SET
    medical_multiplier_low = EXCLUDED.medical_multiplier_low,
    medical_multiplier_high = EXCLUDED.medical_multiplier_high,
    comparative_fault_rule = EXCLUDED.comparative_fault_rule,
    notes = EXCLUDED.notes,
    source = EXCLUDED.source,
    updated_at = now();
