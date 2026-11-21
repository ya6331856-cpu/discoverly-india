export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  public: {
    Tables: {
      audit_logs: {
        Row: {
          action: string
          actor_user_id: string | null
          created_at: string
          entity_id: string | null
          entity_type: string
          id: number
          metadata: Json
        }
        Insert: {
          action: string
          actor_user_id?: string | null
          created_at?: string
          entity_id?: string | null
          entity_type: string
          id?: never
          metadata?: Json
        }
        Update: {
          action?: string
          actor_user_id?: string | null
          created_at?: string
          entity_id?: string | null
          entity_type?: string
          id?: never
          metadata?: Json
        }
        Relationships: []
      }
      categories: {
        Row: {
          category_type: string
          created_at: string
          description: string | null
          id: string
          is_active: boolean
          name: string
          parent_id: string | null
          slug: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          category_type?: string
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          name: string
          parent_id?: string | null
          slug: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          category_type?: string
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          name?: string
          parent_id?: string | null
          slug?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "categories_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
        ]
      }
      companies: {
        Row: {
          created_at: string
          created_by: string
          description: string | null
          display_name: string
          employee_range: string | null
          entity_type: string | null
          founded_year: number | null
          id: string
          legal_name: string
          slug: string
          status: string
          updated_at: string
          website_url: string | null
        }
        Insert: {
          created_at?: string
          created_by: string
          description?: string | null
          display_name: string
          employee_range?: string | null
          entity_type?: string | null
          founded_year?: number | null
          id?: string
          legal_name: string
          slug: string
          status?: string
          updated_at?: string
          website_url?: string | null
        }
        Update: {
          created_at?: string
          created_by?: string
          description?: string | null
          display_name?: string
          employee_range?: string | null
          entity_type?: string | null
          founded_year?: number | null
          id?: string
          legal_name?: string
          slug?: string
          status?: string
          updated_at?: string
          website_url?: string | null
        }
        Relationships: []
      }
      company_categories: {
        Row: {
          category_id: string
          company_id: string
          created_at: string
          is_primary: boolean
        }
        Insert: {
          category_id: string
          company_id: string
          created_at?: string
          is_primary?: boolean
        }
        Update: {
          category_id?: string
          company_id?: string
          created_at?: string
          is_primary?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "company_categories_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "company_categories_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      company_locations: {
        Row: {
          address_line: string | null
          city: string | null
          company_id: string
          country_code: string
          created_at: string
          id: string
          is_head_office: boolean
          is_public: boolean
          label: string | null
          latitude: number | null
          locality: string | null
          longitude: number | null
          postal_code: string | null
          state: string | null
          updated_at: string
        }
        Insert: {
          address_line?: string | null
          city?: string | null
          company_id: string
          country_code?: string
          created_at?: string
          id?: string
          is_head_office?: boolean
          is_public?: boolean
          label?: string | null
          latitude?: number | null
          locality?: string | null
          longitude?: number | null
          postal_code?: string | null
          state?: string | null
          updated_at?: string
        }
        Update: {
          address_line?: string | null
          city?: string | null
          company_id?: string
          country_code?: string
          created_at?: string
          id?: string
          is_head_office?: boolean
          is_public?: boolean
          label?: string | null
          latitude?: number | null
          locality?: string | null
          longitude?: number | null
          postal_code?: string | null
          state?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "company_locations_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      company_members: {
        Row: {
          company_id: string
          created_at: string
          member_role: string
          user_id: string
        }
        Insert: {
          company_id: string
          created_at?: string
          member_role?: string
          user_id: string
        }
        Update: {
          company_id?: string
          created_at?: string
          member_role?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "company_members_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      company_profiles: {
        Row: {
          address_visibility: string
          company_id: string
          cover_path: string | null
          created_at: string
          logo_path: string | null
          profile_completeness: number
          public_email: string | null
          public_phone: string | null
          tagline: string | null
          updated_at: string
          whatsapp_url: string | null
        }
        Insert: {
          address_visibility?: string
          company_id: string
          cover_path?: string | null
          created_at?: string
          logo_path?: string | null
          profile_completeness?: number
          public_email?: string | null
          public_phone?: string | null
          tagline?: string | null
          updated_at?: string
          whatsapp_url?: string | null
        }
        Update: {
          address_visibility?: string
          company_id?: string
          cover_path?: string | null
          created_at?: string
          logo_path?: string | null
          profile_completeness?: number
          public_email?: string | null
          public_phone?: string | null
          tagline?: string | null
          updated_at?: string
          whatsapp_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "company_profiles_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: true
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      content_reports: {
        Row: {
          created_at: string
          details: string | null
          id: string
          reason: string
          reporter_user_id: string
          reviewer_note: string | null
          reviewer_user_id: string | null
          status: string
          target_id: string
          target_type: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          details?: string | null
          id?: string
          reason: string
          reporter_user_id: string
          reviewer_note?: string | null
          reviewer_user_id?: string | null
          status?: string
          target_id: string
          target_type: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          details?: string | null
          id?: string
          reason?: string
          reporter_user_id?: string
          reviewer_note?: string | null
          reviewer_user_id?: string | null
          status?: string
          target_id?: string
          target_type?: string
          updated_at?: string
        }
        Relationships: []
      }
      leads: {
        Row: {
          buyer_user_id: string
          company_id: string
          contact_shared_at: string | null
          created_at: string
          id: string
          message: string
          requirement_id: string | null
          status: string
          subject: string
          updated_at: string
        }
        Insert: {
          buyer_user_id: string
          company_id: string
          contact_shared_at?: string | null
          created_at?: string
          id?: string
          message: string
          requirement_id?: string | null
          status?: string
          subject: string
          updated_at?: string
        }
        Update: {
          buyer_user_id?: string
          company_id?: string
          contact_shared_at?: string | null
          created_at?: string
          id?: string
          message?: string
          requirement_id?: string | null
          status?: string
          subject?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "leads_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leads_requirement_id_fkey"
            columns: ["requirement_id"]
            isOneToOne: false
            referencedRelation: "requirements"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          body: string
          created_at: string
          entity_id: string | null
          entity_type: string | null
          id: string
          notification_type: string
          read_at: string | null
          recipient_user_id: string
          title: string
        }
        Insert: {
          body: string
          created_at?: string
          entity_id?: string | null
          entity_type?: string | null
          id?: string
          notification_type: string
          read_at?: string | null
          recipient_user_id: string
          title: string
        }
        Update: {
          body?: string
          created_at?: string
          entity_id?: string | null
          entity_type?: string | null
          id?: string
          notification_type?: string
          read_at?: string | null
          recipient_user_id?: string
          title?: string
        }
        Relationships: []
      }
      offering_categories: {
        Row: {
          category_id: string
          offering_id: string
        }
        Insert: {
          category_id: string
          offering_id: string
        }
        Update: {
          category_id?: string
          offering_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "offering_categories_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "offering_categories_offering_id_fkey"
            columns: ["offering_id"]
            isOneToOne: false
            referencedRelation: "offerings"
            referencedColumns: ["id"]
          },
        ]
      }
      offering_media: {
        Row: {
          alt_text: string | null
          created_at: string
          id: string
          media_type: string
          offering_id: string
          sort_order: number
          storage_path: string
        }
        Insert: {
          alt_text?: string | null
          created_at?: string
          id?: string
          media_type?: string
          offering_id: string
          sort_order?: number
          storage_path: string
        }
        Update: {
          alt_text?: string | null
          created_at?: string
          id?: string
          media_type?: string
          offering_id?: string
          sort_order?: number
          storage_path?: string
        }
        Relationships: [
          {
            foreignKeyName: "offering_media_offering_id_fkey"
            columns: ["offering_id"]
            isOneToOne: false
            referencedRelation: "offerings"
            referencedColumns: ["id"]
          },
        ]
      }
      offerings: {
        Row: {
          availability_status: string
          company_id: string
          created_at: string
          currency: string
          description: string | null
          id: string
          is_published: boolean
          minimum_order_quantity: number | null
          offering_type: string
          price_from: number | null
          price_to: number | null
          slug: string
          title: string
          unit_label: string | null
          updated_at: string
        }
        Insert: {
          availability_status?: string
          company_id: string
          created_at?: string
          currency?: string
          description?: string | null
          id?: string
          is_published?: boolean
          minimum_order_quantity?: number | null
          offering_type: string
          price_from?: number | null
          price_to?: number | null
          slug: string
          title: string
          unit_label?: string | null
          updated_at?: string
        }
        Update: {
          availability_status?: string
          company_id?: string
          created_at?: string
          currency?: string
          description?: string | null
          id?: string
          is_published?: boolean
          minimum_order_quantity?: number | null
          offering_type?: string
          price_from?: number | null
          price_to?: number | null
          slug?: string
          title?: string
          unit_label?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "offerings_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string
          display_name: string | null
          id: string
          preferred_language: string
          updated_at: string
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          display_name?: string | null
          id: string
          preferred_language?: string
          updated_at?: string
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          display_name?: string | null
          id?: string
          preferred_language?: string
          updated_at?: string
        }
        Relationships: []
      }
      quotations: {
        Row: {
          amount: number
          company_id: string
          created_at: string
          currency: string
          details: string | null
          id: string
          lead_id: string
          status: string
          updated_at: string
          valid_until: string | null
        }
        Insert: {
          amount: number
          company_id: string
          created_at?: string
          currency?: string
          details?: string | null
          id?: string
          lead_id: string
          status?: string
          updated_at?: string
          valid_until?: string | null
        }
        Update: {
          amount?: number
          company_id?: string
          created_at?: string
          currency?: string
          details?: string | null
          id?: string
          lead_id?: string
          status?: string
          updated_at?: string
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "quotations_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quotations_lead_id_fkey"
            columns: ["lead_id"]
            isOneToOne: false
            referencedRelation: "leads"
            referencedColumns: ["id"]
          },
        ]
      }
      requirement_matches: {
        Row: {
          company_id: string
          created_at: string
          id: string
          match_reason: Json
          match_score: number | null
          requirement_id: string
          status: string
        }
        Insert: {
          company_id: string
          created_at?: string
          id?: string
          match_reason?: Json
          match_score?: number | null
          requirement_id: string
          status?: string
        }
        Update: {
          company_id?: string
          created_at?: string
          id?: string
          match_reason?: Json
          match_score?: number | null
          requirement_id?: string
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "requirement_matches_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "requirement_matches_requirement_id_fkey"
            columns: ["requirement_id"]
            isOneToOne: false
            referencedRelation: "requirements"
            referencedColumns: ["id"]
          },
        ]
      }
      requirements: {
        Row: {
          budget_max: number | null
          budget_min: number | null
          buyer_user_id: string
          category_id: string | null
          city: string | null
          contact_sharing: string
          country_code: string
          created_at: string
          currency: string
          description: string
          expires_at: string | null
          id: string
          postal_code: string | null
          quantity: number | null
          quantity_unit: string | null
          requirement_type: string
          state: string | null
          status: string
          title: string
          updated_at: string
        }
        Insert: {
          budget_max?: number | null
          budget_min?: number | null
          buyer_user_id: string
          category_id?: string | null
          city?: string | null
          contact_sharing?: string
          country_code?: string
          created_at?: string
          currency?: string
          description: string
          expires_at?: string | null
          id?: string
          postal_code?: string | null
          quantity?: number | null
          quantity_unit?: string | null
          requirement_type?: string
          state?: string | null
          status?: string
          title: string
          updated_at?: string
        }
        Update: {
          budget_max?: number | null
          budget_min?: number | null
          buyer_user_id?: string
          category_id?: string | null
          city?: string | null
          contact_sharing?: string
          country_code?: string
          created_at?: string
          currency?: string
          description?: string
          expires_at?: string | null
          id?: string
          postal_code?: string | null
          quantity?: number | null
          quantity_unit?: string | null
          requirement_type?: string
          state?: string | null
          status?: string
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "requirements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
        ]
      }
      reviews: {
        Row: {
          body: string | null
          company_id: string
          created_at: string
          id: string
          moderation_status: string
          rating: number
          reviewer_user_id: string
          title: string | null
        }
        Insert: {
          body?: string | null
          company_id: string
          created_at?: string
          id?: string
          moderation_status?: string
          rating: number
          reviewer_user_id: string
          title?: string | null
        }
        Update: {
          body?: string | null
          company_id?: string
          created_at?: string
          id?: string
          moderation_status?: string
          rating?: number
          reviewer_user_id?: string
          title?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reviews_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      saved_items: {
        Row: {
          company_id: string | null
          created_at: string
          id: string
          offering_id: string | null
          user_id: string
        }
        Insert: {
          company_id?: string | null
          created_at?: string
          id?: string
          offering_id?: string | null
          user_id: string
        }
        Update: {
          company_id?: string | null
          created_at?: string
          id?: string
          offering_id?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "saved_items_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "saved_items_offering_id_fkey"
            columns: ["offering_id"]
            isOneToOne: false
            referencedRelation: "offerings"
            referencedColumns: ["id"]
          },
        ]
      }
      search_events: {
        Row: {
          clicked_company_id: string | null
          created_at: string
          filters: Json
          id: number
          query_text: string | null
          result_count: number | null
          session_id: string | null
          user_id: string | null
        }
        Insert: {
          clicked_company_id?: string | null
          created_at?: string
          filters?: Json
          id?: never
          query_text?: string | null
          result_count?: number | null
          session_id?: string | null
          user_id?: string | null
        }
        Update: {
          clicked_company_id?: string | null
          created_at?: string
          filters?: Json
          id?: never
          query_text?: string | null
          result_count?: number | null
          session_id?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "search_events_clicked_company_id_fkey"
            columns: ["clicked_company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      service_areas: {
        Row: {
          city: string | null
          company_id: string
          country_code: string
          created_at: string
          id: string
          postal_code: string | null
          state: string | null
        }
        Insert: {
          city?: string | null
          company_id: string
          country_code?: string
          created_at?: string
          id?: string
          postal_code?: string | null
          state?: string | null
        }
        Update: {
          city?: string | null
          company_id?: string
          country_code?: string
          created_at?: string
          id?: string
          postal_code?: string | null
          state?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "service_areas_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      user_roles: {
        Row: {
          created_at: string
          role: string
          user_id: string
        }
        Insert: {
          created_at?: string
          role: string
          user_id: string
        }
        Update: {
          created_at?: string
          role?: string
          user_id?: string
        }
        Relationships: []
      }
      verification_cases: {
        Row: {
          company_id: string
          created_at: string
          document_path: string | null
          expires_at: string | null
          id: string
          reference_value: string | null
          reviewed_at: string | null
          reviewer_id: string | null
          reviewer_note: string | null
          status: string
          submitted_at: string | null
          updated_at: string
          verification_type: string
        }
        Insert: {
          company_id: string
          created_at?: string
          document_path?: string | null
          expires_at?: string | null
          id?: string
          reference_value?: string | null
          reviewed_at?: string | null
          reviewer_id?: string | null
          reviewer_note?: string | null
          status?: string
          submitted_at?: string | null
          updated_at?: string
          verification_type: string
        }
        Update: {
          company_id?: string
          created_at?: string
          document_path?: string | null
          expires_at?: string | null
          id?: string
          reference_value?: string | null
          reviewed_at?: string | null
          reviewer_id?: string | null
          reviewer_note?: string | null
          status?: string
          submitted_at?: string | null
          updated_at?: string
          verification_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "verification_cases_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      public_company_locations: {
        Row: {
          address_line: string | null
          city: string | null
          company_id: string | null
          country_code: string | null
          id: string | null
          is_head_office: boolean | null
          label: string | null
          locality: string | null
          postal_code: string | null
          state: string | null
        }
        Relationships: [
          {
            foreignKeyName: "company_locations_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      create_business_profile: {
        Args: {
          p_business_type_category_id: string
          p_city: string
          p_description: string
          p_display_name: string
          p_entity_type: string
          p_industry_category_id: string
          p_legal_name: string
          p_public_email: string
          p_public_phone: string
          p_slug: string
          p_state: string
          p_tagline: string
          p_website_url: string
        }
        Returns: string
      }
      create_requirement_and_match: {
        Args: {
          p_budget_max?: number
          p_budget_min?: number
          p_category_id: string
          p_city?: string
          p_description: string
          p_quantity?: number
          p_quantity_unit?: string
          p_requirement_type: string
          p_state?: string
          p_title: string
        }
        Returns: Json
      }
      is_company_admin: {
        Args: { target_company_id: string }
        Returns: boolean
      }
      is_company_member: {
        Args: { target_company_id: string }
        Returns: boolean
      }
      search_businesses: {
        Args: {
          category_slug?: string
          city_filter?: string
          result_limit?: number
          result_offset?: number
          search_query?: string
          state_filter?: string
        }
        Returns: {
          category_names: string[]
          city: string
          company_id: string
          description: string
          display_name: string
          relevance_score: number
          slug: string
          state: string
          website_url: string
        }[]
      }
      submit_business_quotation: {
        Args: {
          p_amount: number
          p_details: string
          p_lead_id: string
          p_valid_until?: string
        }
        Returns: string
      }
      update_business_profile: {
        Args: {
          p_business_type_category_id: string
          p_city: string
          p_company_id: string
          p_description: string
          p_display_name: string
          p_entity_type: string
          p_industry_category_id: string
          p_legal_name: string
          p_logo_path?: string
          p_public_email: string
          p_public_phone: string
          p_state: string
          p_tagline: string
          p_website_url: string
        }
        Returns: string
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
